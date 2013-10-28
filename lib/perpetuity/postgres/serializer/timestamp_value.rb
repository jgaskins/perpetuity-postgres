require 'perpetuity/postgres/serializer/text_value'

module Perpetuity
  class Postgres
    class Serializer
      class TimestampValue
        attr_reader :time
        def initialize time
          @time = time
        end

        def year
          time.year
        end

        def month
          '%02d' % time.month
        end

        def day
          '%02d' % time.day
        end

        def hour
          '%02d' % time.hour
        end

        def minute
          '%02d' % time.min
        end

        def second
          '%02d.%6d' % [time.sec, time.usec]
        end

        def offset
          time.strftime('%z')
        end

        def to_s
          string = TextValue.new("#{year}-#{month}-#{day} #{hour}:#{minute}:#{second}#{offset}").to_s
          "#{string}::timestamptz"
        end
      end
    end
  end
end
