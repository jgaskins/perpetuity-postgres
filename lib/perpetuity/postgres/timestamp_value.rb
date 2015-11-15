require 'perpetuity/postgres/text_value'

module Perpetuity
  class Postgres
    class TimestampValue
      attr_reader :time
      def initialize time
        @time = time
      end

      def self.from_sql sql_value
        match = sql_value =~ /(\d{4})-(\d{2})-(\d{2}) (\d{2}):(\d{2}):(\d{2}).(\d+)([-+]\d{2})?/
        return nil unless match

        offset = $8 ? "#$8:00" : '+00:00'
        new Time.new($1.to_i, $2.to_i, $3.to_i, $4.to_i, $5.to_i, "#$6.#$7".to_f, offset)
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
