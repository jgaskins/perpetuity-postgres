require 'perpetuity/postgres/query'

module Perpetuity
  class Postgres
    class NegatedQuery
      attr_reader :query

      def initialize &block
        @query = Query.new(&block)
      end

      def to_db
        "NOT (#{query.to_db})"
      end

      def to_s
        to_db
      end
    end
  end
end
