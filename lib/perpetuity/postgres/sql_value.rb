require 'perpetuity/postgres/text_value'
require 'perpetuity/postgres/timestamp_value'
require 'perpetuity/postgres/numeric_value'
require 'perpetuity/postgres/null_value'
require 'perpetuity/postgres/boolean_value'

module Perpetuity
  class Postgres
    class SQLValue
      attr_reader :value

      def initialize value
        @value = case value
                 when String, Symbol
                   TextValue.new(value)
                 when Time
                   TimestampValue.new(value)
                 when Fixnum, Float
                   NumericValue.new(value)
                 when nil
                   NullValue.new
                 when true, false
                   BooleanValue.new(value)
                 end.to_s
      end

      def to_s
        value
      end

      def == other
        if other.is_a? String
          value == other
        else
          value == other.value
        end
      end
    end
  end
end
