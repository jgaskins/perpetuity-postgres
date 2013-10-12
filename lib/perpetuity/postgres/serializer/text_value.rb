module Perpetuity
  class Postgres
    class Serializer
      class TextValue
        def initialize value
          @value = value
        end

        def to_s
          "'#{@value}'"
        end
      end
    end
  end
end

