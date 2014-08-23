require 'date'

module Perpetuity
  class Postgres
    class DateValue
      attr_reader :date

      def initialize date
        @date = date
      end

      def self.from_sql date_string
        new(Date.parse(date_string))
      end

      def to_date
        date
      end

      def to_s
        "'#{date.to_s}'::date"
      end

      def value
        date
      end
    end
  end
end
