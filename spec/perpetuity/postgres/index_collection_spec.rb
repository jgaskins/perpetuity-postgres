require 'perpetuity/postgres/index_collection'
require 'perpetuity/attribute'

module Perpetuity
  class Postgres
    describe IndexCollection do
      let(:indexes) { IndexCollection.new(Object) }

      it 'knows which table it is indexing' do
        indexes.table.should == 'Object'
      end

      it 'iterates over its indexes' do
        indexes << 1
        indexes.map { |index| index.to_s }.should include '1'
      end

      it 'converts to an array' do
        indexes.to_ary.should == []
      end

      it 'removes indexes based on a block' do
        indexes << double('Index', name: 'lol')
        indexes.reject! { |index| index.name == 'lol' }
        indexes.map(&:name).should_not include 'lol'
      end
    end
  end
end
