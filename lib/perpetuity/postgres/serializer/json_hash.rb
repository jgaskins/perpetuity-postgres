require_relative 'json_string_value'
require_relative 'numeric_value'

module Perpetuity
  class Postgres
    class Serializer
      class JSONHash
        def initialize value
          @value = value
        end

        def to_s
          "'{#{serialize_elements}}'"
        end

        def serialize_elements
          string = ''
          @value.each do |key, value|
            string << JSONStringValue.new(key) << ':'

            string << if value.is_a? Numeric
              NumericValue.new(value)
            elsif value.is_a? String
              JSONStringValue.new(value)
            end
          end

          string
        end
      end
    end
  end
end
