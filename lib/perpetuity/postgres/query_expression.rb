require 'perpetuity/postgres/query_union'
require 'perpetuity/postgres/query_intersection'
require 'perpetuity/postgres/sql_value'

module Perpetuity
  class Postgres
    class QueryExpression
      attr_accessor :attribute, :comparator, :value
      def initialize attribute, comparator, value
        @attribute = attribute
        @comparator = comparator
        @value = value
      end

      def to_db
        if value.nil?
          if comparator == :==
            "#{attribute} IS NULL"
          elsif comparator == :!=
            "#{attribute} IS NOT NULL"
          end
        else
          public_send comparator
        end
      end

      def sql_value value=self.value
        if value.is_a? String or value.is_a? Symbol
          SQLValue.new(value)
        elsif value.is_a? Regexp
          "'#{value.to_s.sub(/\A\(\?i?-mi?x\:/, '').sub(/\)\z/, '')}'"
        elsif value.is_a? Time
          SQLValue.new(value)
        elsif value.is_a? Array
          value.map! do |element|
            sql_value(element)
          end
          "(#{value.join(',')})"
        else
          value
        end
      end

      def ==
        "#{attribute} = #{sql_value}"
      end

      def <
        "#{attribute} < #{sql_value}"
      end

      def <=
        "#{attribute} <= #{sql_value}"
      end

      def >
        "#{attribute} > #{sql_value}"
      end

      def >=
        "#{attribute} >= #{sql_value}"
      end

      def !=
        "#{attribute} != #{sql_value}"
      end

      def in
        case sql_value
        when Range
          "#{attribute} BETWEEN #{SQLValue.new(sql_value.min)} AND #{SQLValue.new(sql_value.max)}"
        else
          "#{attribute} IN #{sql_value}"
        end
      end

      def =~
        regexp_comparator = if value.casefold?
                              '~*'
                            else
                              '~'
                            end
        "#{attribute} #{regexp_comparator} #{sql_value}"
      end

      def | other
        QueryUnion.new(self, other)
      end

      def & other
        QueryIntersection.new(self, other)
      end
    end
  end
end
