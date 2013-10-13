module Perpetuity
  class Postgres
    class Serializer
      class JSONStringValue
        def initialize value
          @value = value
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
end
