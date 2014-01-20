require 'perpetuity/postgres/query_expression'
require 'perpetuity/postgres/sql_function'

module Perpetuity
  class Postgres
    class QueryAttribute
      attr_reader :name

      def initialize name
        @name = name
      end

      %w(!= <= < == > >= =~).each do |comparator|
        eval <<METHOD
        def #{comparator} value
          QueryExpression.new self, :#{comparator}, value
        end
METHOD
      end

      def in collection
        QueryExpression.new self, :in, collection
      end

      def nil?
        QueryExpression.new self, :==, nil
      end

      def count
        SQLFunction.new('json_array_length', self)
      end

      def any?
        QueryExpression.new count, :>, 0
      end

      def none?
        QueryExpression.new count, :==, 0
      end

      def id
        QueryAttribute.new "#{name}->'__metadata__'->>'id'"
      end

      def to_s
        name.to_s
      end

      def to_db
        (self != nil).to_db
      end
    end
  end
end
