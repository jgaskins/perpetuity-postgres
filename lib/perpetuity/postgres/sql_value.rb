require 'perpetuity/postgres/text_value'
require 'perpetuity/postgres/timestamp_value'

module Perpetuity
  class Postgres
    class SQLValue
      attr_reader :value

      def initialize value
        @value = if value.is_a? String or value.is_a? Symbol
                   TextValue.new(value)
                 elsif value.is_a? Time
                   TimestampValue.new(value)
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
