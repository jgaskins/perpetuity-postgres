require 'perpetuity/postgres/query_attribute'

module Perpetuity
  class Postgres
    class Query
      attr_reader :query, :klass

      def initialize &block
        @query = block
      end

      def to_db
        query.call(self).to_db
      end

      def method_missing name
        QueryAttribute.new(name)
      end
    end
  end
end
