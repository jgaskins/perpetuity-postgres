require 'perpetuity/postgres/query_attribute'
require 'perpetuity/postgres/nil_query'

module Perpetuity
  class Postgres
    class Query
      attr_reader :query, :klass

      def initialize &block
        if block_given?
          @query = block
        else
          @query = proc { NilQuery.new }
        end
      end

      def to_db
        query.call(self).to_db
      end

      def to_str
        to_db
      end

      def method_missing name
        QueryAttribute.new(name)
      end
    end
  end
end
