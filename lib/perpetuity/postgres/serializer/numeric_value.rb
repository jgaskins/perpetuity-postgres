module Perpetuity
  class Postgres
    class Serializer
      class NumericValue
        def initialize value
          @value = value
        end

        def to_s
          @value.to_s
        end
      end
    end
  end
end
