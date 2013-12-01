module Perpetuity
  class Postgres
    class TextValue
      def initialize value
        @value = value.to_s.gsub("'") { "''" }
      end

      def to_s
        "'#{@value}'"
      end
    end
  end
end

