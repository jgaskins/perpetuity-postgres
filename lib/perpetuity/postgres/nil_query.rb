module Perpetuity
  class Postgres
    class NilQuery
      def to_db
        'TRUE'
      end
    end
  end
end
