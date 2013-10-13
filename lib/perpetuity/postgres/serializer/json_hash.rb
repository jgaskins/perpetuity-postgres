require_relative 'json_string_value'
require_relative 'numeric_value'

module Perpetuity
  class Postgres
    class Serializer
      class JSONHash
        def initialize value, location=:outer
          @value = value
          @location = location
        end

        def to_s
          if @location == :outer
            "'{#{serialize_elements}}'"
          else
            "{#{serialize_elements}}"
          end
        end

        def serialize_elements
          @value.map do |key, value|
            string = ''
            string << JSONStringValue.new(key) << ':'

            string << if value.is_a? Numeric
              NumericValue.new(value)
            elsif value.is_a? String
              JSONStringValue.new(value)
            elsif value.is_a? Hash
              JSONHash.new(value, :inner)
            elsif value.is_a? Class
              JSONStringValue.new(value.to_s)
            else
              p value
            end
          end.join(',')
        end

        def to_str
          to_s
        end
      end
    end
  end
end
