require 'perpetuity/postgres/table_name'

module Perpetuity
  class Postgres
    class SQLSelect
      attr_reader :table, :where, :limit

      def initialize options={}
        @table = options.fetch(:table)
        @where = options[:where]
        @limit = options[:limit]
      end

      def to_s
        "SELECT * FROM #{TableName.new(table)}" << where_clause.to_s << limit_clause.to_s
      end

      def where_clause
        if where
          " WHERE #{where}"
        end
      end

      def limit_clause
        if limit
          " LIMIT #{limit}"
        end
      end
    end
  end
end
