module Perpetuity
  class Postgres
    class SQLFunction
      attr_reader :name, :args
      def initialize name, *args
        @name = name
        @args = args
      end

      def to_s
        "#{name}(#{args.join(',')})"
      end
    end
  end
end
