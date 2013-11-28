module Perpetuity
  class Postgres
    class BooleanValue
      def initialize value
        @value = value
      end

      def to_s
        if @value
          'TRUE'
        else
          'FALSE'
        end
      end
    end
  end
end
