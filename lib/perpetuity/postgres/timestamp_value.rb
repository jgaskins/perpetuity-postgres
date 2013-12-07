require 'perpetuity/postgres/text_value'

module Perpetuity
  class Postgres
    class TimestampValue
      attr_reader :time
      def initialize time
        @time = time
      end

      def self.from_sql sql_value
        date, time = sql_value.split(/ /)
        year, month, day = date.split(/-/)
        hour, minute, seconds_with_offset = time.split(/:/)
        second = seconds_with_offset[/\d+\.\d+/].to_f
        offset = seconds_with_offset[/(\+|\-)\d+/] + ':00'

        new Time.new(year, month, day, hour, minute, second, offset)
      end

      def to_time
        time
      end

      def value
        time
      end

      def year
        time.year
      end

      def month
        zero_pad(time.month)
      end

      def day
        zero_pad(time.day)
      end

      def hour
        zero_pad(time.hour)
      end

      def minute
        zero_pad(time.min)
      end

      def second
        '%02d.%06d' % [time.sec, time.usec]
      end

      def offset
        time.strftime('%z')
      end

      def to_s
        string = TextValue.new("#{year}-#{month}-#{day} #{hour}:#{minute}:#{second}#{offset}").to_s
        "#{string}::timestamptz"
      end

      private
      def zero_pad n
        '%02d' % n
      end
    end
  end
end
