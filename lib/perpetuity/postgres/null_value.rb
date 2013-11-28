module Perpetuity
  class Postgres
    class NullValue
      def to_s
        'NULL'
      end
    end
  end
end
