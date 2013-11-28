module Perpetuity
  class Postgres
    class NumericValue
      def initialize value
        @value = value
      end

      def to_s
        @value.to_s
      end

      def to_str
        to_s
      end
    end
  end
end
