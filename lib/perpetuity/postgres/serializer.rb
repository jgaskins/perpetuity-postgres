require 'perpetuity/postgres/value_with_attribute'
require 'perpetuity/postgres/serializer/text_value'
require 'perpetuity/postgres/serializer/numeric_value'
require 'perpetuity/postgres/serializer/null_value'
require 'perpetuity/postgres/serializer/boolean_value'
require 'perpetuity/postgres/serializer/json_array'
require 'json'

module Perpetuity
  class Postgres
    class Serializer
      attr_reader :mapper

      def initialize mapper
        @mapper = mapper
      end

      def serialize object
        attrs = mapper.attribute_set.map do |attribute|
          attr_name = attribute.name.to_s
          value = ValueWithAttribute.new(attribute_for(object, attr_name), attribute)
          serialize_attribute(value)
        end.join(',')

        "(#{attrs})"
      end

      def attribute_for object, attr_name
        object.instance_variable_get("@#{attr_name}")
      end

      def serialize_attribute object
        value = object.value rescue object

        if value.is_a? String
          TextValue.new(value)
        elsif value.is_a? Numeric
          NumericValue.new(value)
        elsif value.is_a? Array
          JSONArray.new(value)
        elsif value.is_a? Time

        elsif value.nil?
          NullValue.new
        elsif value == true || value == false
          BooleanValue.new(value)
        elsif !object.embedded?
          serialize_reference(value)
        elsif object.embedded?
          serialize_with_foreign_mapper(value)
        end.to_s
      end

      def serialize_with_foreign_mapper value
        mapper = mapper_registry[value.class]
        mapper.serialize(value)
      end
    end
  end
end
