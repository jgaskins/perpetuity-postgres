require 'perpetuity/attribute'

module Perpetuity
  class Postgres
    class Index
      attr_reader :attributes, :name

      def initialize options={}
        @attributes = options.fetch(:attributes)
        @name       = options.fetch(:name)
        @unique     = options.fetch(:unique) { false }
        @active     = options.fetch(:active) { false }
      end

      def self.from_sql sql_result
        attributes = sql_result['attributes'].gsub(/[{}]/, '').split(',').map do |attr|
          Attribute.new(attr)
        end
        unique = sql_result['unique'] == 't'
        active = sql_result['active'] == 't'
        new(name: sql_result['name'],
            attributes: attributes,
            unique: unique,
            active: active)
      end

      def attribute
        attributes.first
      end

      def attribute_names
        attributes.map { |attr| attr.name.to_s }
      end

      def unique?
        !!@unique
      end

      def active?
        !!@active
      end

      def inactive?
        !active?
      end

      def activate!
        @active = true
      end

      def table
        name.gsub("_#{attributes.map(&:to_s).join('_')}_idx", '')
      end

      def == other
        other.is_a?(self.class) &&
        attributes.map(&:to_s) == other.attributes.map(&:to_s) &&
        name.to_s == other.name.to_s &&
        unique? == other.unique?
      end

      def eql? other
        self == other
      end

      def hash
        name.to_s.hash
      end
    end
  end
end
