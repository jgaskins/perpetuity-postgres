require 'perpetuity'
require 'json'
require 'perpetuity/postgres/connection_pool'
require 'perpetuity/postgres/serializer'
require 'perpetuity/postgres/query'
require 'perpetuity/postgres/negated_query'
require 'perpetuity/postgres/table'
require 'perpetuity/postgres/table/attribute'
require 'perpetuity/postgres/sql_select'
require 'perpetuity/postgres/sql_update'
require 'perpetuity/postgres/index_collection'
require 'perpetuity/postgres/index'

module Perpetuity
  class Postgres
    attr_reader :host, :port, :db, :pool_size, :username, :password,
                :connection

    def initialize options
      @host      = options.fetch(:host) { 'localhost' }
      @port      = options.fetch(:port) { 5432 }
      @db        = options.fetch(:db)
      @pool_size = options.fetch(:pool_size) { 5 }
      @username  = options.fetch(:username) { ENV['USER'] }
      @password  = options.fetch(:password) {}

      @connection ||= ConnectionPool.new(
        db:       db,
        host:     host,
        port:     port,
        username: username,
        password: password,
        pool_size: pool_size
      )
    end

    def insert klass, serialized_objects, attributes
      table = TableName.new(klass)
      data = serialized_objects.reduce(:+)
      sql = "INSERT INTO #{table} #{data} RETURNING id"

      results = connection.execute(sql).to_a
      ids = results.map { |result| cast_id(result['id'], attributes[:id]) }

      ids
    rescue PG::UndefinedTable => e # Table doesn't exist, so we create it.
      retries ||= 0
      retries += 1
      create_table_with_attributes klass, attributes
      retry unless retries > 1
      raise e
    rescue PG::UndefinedColumn => e
      retries ||= 0
      retries += 1
      error ||= nil

      if retries > 1 && e.message == error
        # We've retried more than once and we're getting the same error
        raise
      end

      error = e.message
      if error =~ /column "(.+)" of relation "(.+)" does not exist/
        column_name = $1
        table_name = $2
        add_column table_name, column_name, attributes
        retry
      end

      raise
    end

    def delete ids, klass
      ids = Array(ids)
      table = TableName.new(klass)

      if ids.one?
        id_string = TextValue.new(ids.first)
        sql = "DELETE FROM #{table} WHERE id = #{id_string}"

        connection.execute(sql).to_a
      elsif ids.none?
        # Do nothing, we weren't given anything to delete
      else
        id_string = ids.map { |id| TextValue.new(id) }
        sql = "DELETE FROM #{table} WHERE id IN (#{id_string.join(',')})"

        connection.execute(sql).to_a
      end
    end

    def count klass, query='TRUE', options={}, &block
      where = if block_given?
                query(&block)
              else
                query
              end
      options = translate_options(options).merge(from: klass, where: where)
      table = table_name(klass)
      sql = select 'COUNT(*)', options
      connection.execute(sql).to_a.first['count'].to_i
    rescue PG::UndefinedTable
      # Table does not exist, so there are 0 records
      0
    end

    def find klass, id
      retrieve(klass, query { |o| o.id == id }.to_db).first
    end

    def table_name klass
      TableName.new(klass)
    end

    def delete_all klass
      table = table_name(klass)
      sql = "DELETE FROM #{table}"
      connection.execute(sql)
    rescue PG::UndefinedTable
      # Do nothing. There is already nothing here.
    end

    def query &block
      Query.new(&block)
    end

    def negate_query &block
      NegatedQuery.new(&block)
    end

    def retrieve klass, criteria, options={}
      options = translate_options(options).merge from: klass, where: criteria

      sql = select options
      connection.execute(sql).to_a
    rescue PG::UndefinedTable
      []
    end

    def update klass, id, attributes
      sql = SQLUpdate.new(klass, id, attributes).to_s
      connection.execute(sql).to_a
    rescue PG::UndefinedColumn => e
      if e.message =~ /column "(.*)" of relation "(.*)" does not exist/
        column_name = $1
        table_name = $2
        add_column table_name, column_name, [Attribute.new(column_name, attributes[column_name].class)]
        retry
      else
        raise e
      end
    end

    def index klass, attributes, options={}
      name = "#{klass}_#{Array(attributes).map(&:name).join('_')}_idx"
      index = Index.new(name: name,
                        attributes: Array(attributes),
                        unique: !!options[:unique],
                        active: false)
      indexes(klass) << index
      index
    end

    def indexes klass
      @indexes ||= {}
      @indexes[klass] ||= IndexCollection.new(klass)
    end

    def activate_index! index
      sql = "CREATE "
      sql << "UNIQUE " if index.unique?
      sql << "INDEX ON #{TableName.new(index.table)} (#{index.attribute_names.join(',')})"
      connection.execute(sql)
      index.activate!
    rescue PG::UndefinedTable => e
      create_table_with_attributes index.table, index.attributes
      retry
    end

    def active_indexes table
      sql = <<-SQL
      SELECT pg_class.relname AS name,
             ARRAY(
               SELECT pg_get_indexdef(pg_index.indexrelid, k + 1, true)
               FROM generate_subscripts(pg_index.indkey, 1) AS k
               ORDER BY k
             ) AS attributes,
             pg_index.indisunique AS unique,
             pg_index.indisready AS active
      FROM pg_class
      INNER JOIN pg_index ON pg_class.oid = pg_index.indexrelid
      WHERE pg_class.relname ~ '^#{table}.*idx$'
      SQL

      indexes = connection.execute(sql).map do |index|
        Index.from_sql(index)
      end
      IndexCollection.new(table, indexes)
    end

    def remove_index index
      sql = %Q{DROP INDEX IF EXISTS #{TableName.new(index.name)}}
      connection.execute(sql)
    end

    def translate_options options
      options = options.dup
      if options[:attribute]
        options[:order] = options.delete(:attribute)
        if direction = options.delete(:direction)
          direction = direction.to_s[/(asc|desc)/i]
          options[:order] = { options[:order] => direction }
        end
      end
      if options[:skip]
        options[:offset] = options.delete(:skip)
      end

      options
    end

    def select *args
      SQLSelect.new(*args).to_s
    end

    def drop_table name
      connection.execute "DROP TABLE IF EXISTS #{table_name(name)}"
    end
    alias :drop_collection :drop_table

    def create_table name, attributes
      connection.execute Table.new(name, attributes).create_table_sql
    end

    def has_table? name
      connection.tables.include? name
    end

    def postgresify value
      Serializer.new(nil).serialize_attribute value
    end

    def serialize object, mapper
      Serializer.new(mapper).serialize object
    end

    def serialize_changed_attributes object, original, mapper
      Serializer.new(mapper).serialize_changes object, original
    end

    def cast_id id, id_attribute
      return id if id_attribute.nil?

      if [Bignum, Fixnum, Integer].include? id_attribute.type
        id.to_i
      else
        id
      end
    end

    def unserialize data, mapper
      Serializer.new(mapper).unserialize data
    end

    def increment klass, id, attribute, count=1
      table = TableName.new(klass)
      sql = %Q{UPDATE #{table} SET #{attribute} = #{attribute} + #{count} WHERE id = #{SQLValue.new(id)} RETURNING #{attribute}}
      connection.execute(sql).to_a
    end

    def create_table_with_attributes klass, attributes
      table_attributes = attributes.map do |attr|
        name = attr.name
        type = attr.type
        options = attr.options
        Table::Attribute.new name, type, options
      end
      create_table klass.to_s, table_attributes
    end

    def add_column table_name, column_name, attributes
      attr = attributes.detect { |a| a.name.to_s == column_name.to_s }
      column = Table::Attribute.new(attr.name, attr.type, attr.options)

      sql = %Q(ALTER TABLE "#{table_name}" ADD #{column.sql_declaration})
      connection.execute sql
    end
  end
end
