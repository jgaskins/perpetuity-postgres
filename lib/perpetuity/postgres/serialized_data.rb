require 'perpetuity/postgres/text_value'

module Perpetuity
  class Postgres
    class SerializedData
      include Enumerable
      attr_reader :column_names, :values
      def initialize column_names, *values
        @column_names = column_names.map(&:to_s)
        @values = values
      end

      def to_s
        value_strings = values.map { |data| "(#{data.join(',')})" }.join(',')
        "(#{column_names.join(',')}) VALUES #{value_strings}"
      end

      def [] key
        index = column_names.index(key.to_s)
        values.first[index]
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
        combined = self.class.new(column_names.dup, *(values.dup))
        combined.values << other.values

        combined
      end

      def any?
        values.flatten.any?
      end

      def each
        data = values.first
        column_names.each_with_index { |column, index| yield(column, data[index]) }
        self
      end

      def - other
        values = self.values.first
        modified_values = values - other.values.first
        modified_columns = column_names.select.with_index { |col, index|
          values[index] != other.values.first[index]
        }

        SerializedData.new(modified_columns, modified_values)
      end

      def == other
        other.is_a? SerializedData and
        other.column_names == column_names and
        other.values == values
      end
    end
  end
end
