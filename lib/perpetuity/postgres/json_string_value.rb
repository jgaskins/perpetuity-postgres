module Perpetuity
  class Postgres
    class JSONStringValue
      def initialize value
        @value = value
          .to_s
          .gsub('"') { '\\"' }
          .gsub("'") { "''" }
      end

      def to_s
        %Q{"#{@value}"}
      end

      def to_str
        to_s
      end
    end
  end
end
