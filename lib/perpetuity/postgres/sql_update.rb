require 'perpetuity/postgres/table_name'
require 'perpetuity/postgres/sql_value'

module Perpetuity
  class Postgres
    class SQLUpdate
      attr_reader :klass, :id, :attributes

      def initialize klass, id, attributes
        @class = klass
        @id = id
        @attributes = attributes
      end

      def to_s
        sql = "UPDATE #{TableName.new(@class)}"
        if attributes.any?
          sql << " SET "
          sql << attributes.map do |name, value|
            value = SQLValue.new(value) if attributes.is_a? Hash
            "#{name} = #{value}"
          end.join(',')
        end
        sql << " WHERE id = #{SQLValue.new(id)}"
      end
    end
  end
end
