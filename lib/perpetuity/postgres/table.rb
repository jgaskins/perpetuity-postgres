require 'perpetuity/postgres/table/attribute'
require 'perpetuity/postgres/expression'
require 'perpetuity/postgres/table_name'

module Perpetuity
  class Postgres
    class Table
      attr_reader :name, :attributes
      def initialize name, attributes
        @name = TableName.new(name)
        @attributes = attributes.to_a

        generate_id_attribute unless has_id_attribute?
      end

      def create_table_sql
        sql = "CREATE TABLE IF NOT EXISTS #{name} ("
        sql << attributes.map(&:sql_declaration).join(', ')
        sql << ')'
      end

      def has_id_attribute?
        attributes.any? { |attr| attr.name.to_s == 'id' }
      end

      def generate_id_attribute
        id = Attribute.new('id', Attribute::UUID, primary_key: true, default: Expression.new('uuid_generate_v4()'))
        attributes.unshift id
      end

      def to_s
        name.to_s
      end
    end
  end
end
