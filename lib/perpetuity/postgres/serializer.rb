require 'perpetuity/postgres/sql_value'
require 'perpetuity/postgres/serialized_data'
require 'perpetuity/postgres/value_with_attribute'
require 'perpetuity/postgres/json_array'
require 'perpetuity/postgres/json_hash'
require 'perpetuity/data_injectable'
require 'json'

module Perpetuity
  class Postgres
    class Serializer
      include DataInjectable

      SERIALIZABLE_CLASSES = [Fixnum, Float, String, Hash, Time, TrueClass, FalseClass, NilClass, Array]
      attr_reader :mapper, :mapper_registry

      def initialize mapper
        @mapper = mapper
        @mapper_registry = mapper.mapper_registry if mapper
      end

      def serialize object
        attrs = mapper.attribute_set.map do |attribute|
          attr_name = attribute.name.to_s
          value = ValueWithAttribute.new(attribute_for(object, attr_name), attribute)
          serialize_attribute(value)
        end
        column_names = mapper.attributes

        SerializedData.new(column_names, attrs)
      end

      def unserialize data
        if data.is_a? Array
          data.map do |datum|
            object = mapper.mapped_class.allocate
            datum.each do |attribute_name, value|
              inject_attribute object, attribute_name, unserialize_attribute(value)
            end

            object
          end
        else
          unserialize([data]).first
        end
      end

      def unserialize_attribute value
        if possible_json_value?(value)
          value = JSON.parse(value) rescue value
          if value.is_a? Array
            value = value.map { |v| unserialize_attribute(v) }
          else
            value
          end
        end
        if foreign_object? value
          value = unserialize_foreign_object value
        end

        value
      end

      def possible_json_value? value
        value.is_a?(String) && %w([ {).include?(value[0])
      end

      def foreign_object? value
        value.is_a?(Hash) && value.has_key?('__metadata__')
      end

      def unserialize_foreign_object data
        metadata = data.delete('__metadata__')
        klass = Object.const_get(metadata['class'])
        if metadata.has_key? 'id'
          id = metadata['id']
          return unserialize_reference(klass, id)
        end

        serializer = serializer_for(klass)
        serializer.unserialize(data)
      end

      def unserialize_reference klass, id
        Reference.new(klass, id)
      end

      def serializer_for klass
        Serializer.new(mapper_registry[klass])
      end

      def attribute_for object, attr_name
        object.instance_variable_get("@#{attr_name}")
      end

      def serialize_attribute object
        value = object.value rescue object

        if value.is_a? String
          SQLValue.new(value)
        elsif value.is_a? Numeric
          SQLValue.new(value)
        elsif value.is_a? Array
          serialize_array(object)
        elsif value.is_a? Time
          SQLValue.new(value)
        elsif value.nil?
          SQLValue.new(value)
        elsif value == true || value == false
          SQLValue.new(value)
        elsif !object.embedded?
          serialize_reference(value)
        elsif object.embedded?
          serialize_with_foreign_mapper(value)
        end.to_s
      end

      def serialize_array object
        value = object.value rescue object
        array = value.map do |item|
          if SERIALIZABLE_CLASSES.include? item.class
            item
          elsif object.embedded?
            serialize_with_foreign_mapper item
          else
            serialize_reference item
          end
        end

        JSONArray.new(array)
      end

      def serialize_to_hash value
        Hash[
          mapper.attribute_set.map do |attribute|
            attr_name = attribute.name
            attr_value = attribute_for(value, attr_name)
            [attr_name, attr_value]
          end
        ]
      end

      def serialize_reference value
        unless mapper.persisted? value
          mapper_registry[value.class].insert value
        end

        json = {
          __metadata__: {
            class: value.class,
            id: mapper.id_for(value)
          }
        }

        JSONHash.new(json)
      end

      def serialize_with_foreign_mapper value
        mapper = mapper_registry[value.class]
        serializer = Serializer.new(mapper)
        attr = serializer.serialize_to_hash(value)
        attr.merge!('__metadata__' => { 'class' => value.class })

        JSONHash.new(attr)
      end
    end
  end
end
