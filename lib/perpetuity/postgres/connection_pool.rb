require 'perpetuity/postgres/connection'
require 'thread'

module Perpetuity
  class Postgres
    class ConnectionPool
      attr_reader :connections, :size

      def initialize options={}
        @connections = Queue.new
        @size = options.delete(:pool_size) { 5 }
        @size.times do
          connections << Connection.new(options)
        end
      end

      def lend_connection
        if block_given?
          connection = connections.pop
          yield connection
        end
      ensure
        connections << connection
      end

      def execute sql
        lend_connection do |connection|
          connection.execute sql
        end
      end

      def tables
        lend_connection do |connection|
          connection.tables
        end
      end
    end
  end
end
