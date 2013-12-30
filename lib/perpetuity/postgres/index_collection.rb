require 'set'

module Perpetuity
  class Postgres
    class IndexCollection
      include Enumerable

      attr_reader :table

      def initialize table, *indexes
        @table = table.to_s
        @indexes = indexes.flatten.to_set
      end

      def << index
        @indexes << index
      end

      def each
        @indexes.each { |index| yield index }
      end

      def reject! &block
        @indexes.reject!(&block)
      end

      def to_a
        @indexes.to_a
      end

      def to_ary
        to_a
      end

      def - other
        difference = self.class.new(table)
        each do |index|
          unless other.include? index
            difference << index
          end
        end

        difference
      end

      def == other
        table == other.table &&
        count == other.count &&
        (self - other).empty?
      end
    end
  end
end
