require 'perpetuity'
require 'json'
require 'perpetuity/postgres/connection'
require 'perpetuity/postgres/serializer'
require 'perpetuity/postgres/query'
require 'perpetuity/postgres/negated_query'
require 'perpetuity/postgres/table'
require 'perpetuity/postgres/table/attribute'
require 'perpetuity/postgres/sql_select'

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

      @connection ||= Connection.new(
        db:       db,
        host:     host,
        port:     port,
        username: username,
        password: password,
      )
    end

    def insert klass, serialized_objects, attributes
      table = TableName.new(klass)
      data = serialized_objects.reduce(:+)
      sql = "INSERT INTO #{table} #{data} RETURNING id"

      results = connection.execute(sql).to_a
      ids = results.map { |result| result['id'] }

      ids
    rescue PG::UndefinedTable => e # Table doesn't exist, so we create it.
      retries ||= 0
      retries += 1
      create_table_with_attributes klass, attributes
      retry unless retries > 1
      raise e
    end

    def delete id, klass
      table = TableName.new(klass)
      id_string = TextValue.new(id)
      sql = "DELETE FROM #{table} WHERE id = #{id_string}"
      connection.execute(sql).to_a
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

    def translate_options options
      options = options.dup
      if options[:attribute]
        options[:order] = options.delete(:attribute)
        if direction = options.delete(:direction)
          direction = direction.to_s[/\w{1,2}sc/i]
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

    def unserialize data, mapper
      Serializer.new(mapper).unserialize data
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
  end
end
