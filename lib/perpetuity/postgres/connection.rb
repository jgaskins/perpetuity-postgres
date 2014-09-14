require 'pg'

module Perpetuity
  class Postgres
    class Connection
      attr_reader :options

      def initialize options={}
        @options = sanitize_options(options)
      end

      def db
        options[:dbname]
      end

      def pg_connection
        @pg_connection ||= connect
      end

      def connect
        @pg_connection = PG.connect(options)
        @pg_connection.exec 'SET client_min_messages TO warning'
        @pg_connection
      rescue PG::ConnectionBad => e
        tries ||= 0
        connect_options = options.dup
        connect_options.delete :dbname

        conn = PG.connect connect_options
        conn.exec "CREATE DATABASE #{db}"
        conn.close

        if tries.zero?
          retry
        else
          raise e
        end
      end

      def active?
        !!@pg_connection
      end

      def execute sql
        pg_connection.exec sql
      rescue PG::AdminShutdown, PG::UnableToSend => e
        # server closed the connection unexpectedly
        # Try to reconnect 3 times in case it's just a server restart.
        unable_to_send_retries ||= 0
        if unable_to_send_retries < 3
          connect
          unable_to_send_retries += 1
          sleep 1
          retry
        else
          raise
        end
      rescue PG::UndefinedFunction => e
        if e.message =~ /uuid_generate/
          use_uuid_extension
          retry
        else
          raise
        end
      end

      def tables
        sql = "SELECT table_name FROM information_schema.tables "
        sql << "WHERE table_schema = 'public'"

        result = execute(sql)
        result.to_a.map { |r| r['table_name'] }
      end

      def sanitize_options options
        options = options.dup
        db = options.delete(:db)
        username = options.delete(:username)

        if db
          options[:dbname] = db
        end

        if username
          options[:user] = username
        end

        options
      end

      private
      def use_uuid_extension
        execute 'CREATE EXTENSION "uuid-ossp"'
      rescue PG::DuplicateObject
        # Ignore. It just means the extension's already been loaded.
      end
    end
  end
end
