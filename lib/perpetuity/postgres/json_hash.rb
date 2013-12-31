require 'perpetuity/postgres/sql_value'
require 'perpetuity/postgres/json_string_value'

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

          string << if [String, Class].include? value.class
            JSONStringValue.new(value.to_s)
          elsif [true, false].include? value
            value.to_s
          elsif value.nil?
            'null'
          else
            SQLValue.new(value).to_s
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
