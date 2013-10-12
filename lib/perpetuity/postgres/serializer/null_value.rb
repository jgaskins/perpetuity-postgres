module Perpetuity
  class Postgres
    class Serializer
      class NullValue
        def to_s
          'NULL'
        end
      end
    end
  end
end
