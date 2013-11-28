require 'perpetuity/postgres/numeric_value'
require 'perpetuity/postgres/json_string_value'
require 'perpetuity/postgres/json_hash'

module Perpetuity
  class Postgres
    class JSONArray
      def initialize value
        @value = value
      end

      def to_s
        "'[#{serialize_elements}]'"
      end

      def serialize_elements
        @value.map do |element|
          if element.is_a? Numeric
            NumericValue.new(element)
          elsif element.is_a? String
            JSONStringValue.new(element)
          elsif element.is_a? Hash
            JSONHash.new(element, :inner)
          elsif element.is_a? JSONHash
            JSONHash.new(element.to_hash, :inner)
          end
        end.join(',')
      end
    end
  end
end
