require 'perpetuity/postgres/json_string_value'
require 'perpetuity/postgres/numeric_value'

module Perpetuity
  class Postgres
    class JSONHash
      def initialize value, location=:outer
        @value = value
        @location = location
      end

      def to_s
        if @location == :outer
          "'{#{serialize_elements}}'"
        else
          "{#{serialize_elements}}"
        end
      end

      def to_hash
        @value
      end

      def serialize_elements
        @value.map do |key, value|
          string = ''
          string << JSONStringValue.new(key) << ':'

          string << if value.is_a? Numeric
                      NumericValue.new(value)
          elsif value.is_a? String
            JSONStringValue.new(value)
          elsif value.is_a? Hash
            JSONHash.new(value, :inner)
          elsif value.is_a? Class
            JSONStringValue.new(value.to_s)
          elsif [true, false].include? value
            value.to_s
          else
            value
          end
        end.join(',')
      end

      def to_str
        to_s
      end

      def == other
        other.is_a? self.class and
        other.to_hash == to_hash
      end
    end
  end
end
