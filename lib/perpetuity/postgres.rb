require 'perpetuity'
require 'json'
require 'perpetuity/postgres/connection'
require 'perpetuity/postgres/serializer'
require 'perpetuity/postgres/query'
require 'perpetuity/postgres/table'
require 'perpetuity/postgres/table/attribute'

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

    def insert klass, data, attributes
      table = table_name(klass)
      column_names = attributes.map { |attr| attr.name.to_s }.join(',')
      values = data.join(',')
      sql = "INSERT INTO #{table} (#{column_names}) VALUES "
      sql << "#{values} RETURNING id"

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

    def count klass
      table = table_name(klass)
      sql = "SELECT COUNT(*) FROM #{table}"
      connection.execute(sql).to_a.first['count'].to_i
    rescue PG::UndefinedTable
      # Table does not exist, so there are 0 records
      0
    end

    def find klass, id
      retrieve(klass, query { |o| o.id == id }.to_db).first
    end

    def table_name klass
      klass.to_s.inspect
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

    def negate_query
    end

    def retrieve klass, criteria, options={}
      sql = "SELECT * FROM #{table_name(klass)} WHERE "
      sql << criteria
      connection.execute(sql).to_a
    end

    def drop_table name
      connection.execute "DROP TABLE IF EXISTS #{name.inspect}"
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
