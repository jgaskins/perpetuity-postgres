require 'perpetuity/postgres/text_value'

module Perpetuity
  class Postgres
    class SerializedData
      attr_reader :column_names, :values
      def initialize column_names, *values
        @column_names = column_names.map(&:to_s)
        @values = values
      end

      def to_s
        value_strings = values.map { |data| "(#{data.join(',')})" }.join(',')
        "(#{column_names.join(',')}) VALUES #{value_strings}"
      end

      def []= column, value
        value = TextValue.new(value)
        if column_names.include? column
          index = column_names.index(column)
          values.first[index] = value
        else
          column_names << column
          values.first << value
        end
      end

      def + other
        combined = dup
        combined.values << other.values

        combined
      end

      def any?
        values.any?
      end

      def map
        data = values.first
        mapped = Array.new(column_names.size)
        column_names.each_with_index { |column, index| mapped[index] = yield(column, data[index]) }
        mapped
      end
    end
  end
end
