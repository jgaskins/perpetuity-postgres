module Perpetuity
  class Postgres
    InvalidTableName = Class.new(StandardError)
    class TableName
      def initialize name
        @name = name.to_s
        raise InvalidTableName, "PostgreSQL table name cannot contain double quotes" if @name.include? '"'
      end

      def to_s
        @name.to_s.inspect
      end

      def == other
        if other.is_a? String
          other == @name
        else
          to_s == other.to_s
        end
      end
    end
  end
end
