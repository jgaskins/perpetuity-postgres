require 'perpetuity/postgres/index_collection'
require 'perpetuity/attribute'

module Perpetuity
  class Postgres
    describe IndexCollection do
      let(:indexes) { IndexCollection.new(Object) }

      it 'knows which table it is indexing' do
        expect(indexes.table).to be == 'Object'
      end

      it 'iterates over its indexes' do
        indexes << 1
        expect(indexes.map { |index| index.to_s }).to include '1'
      end

      it 'converts to an array' do
        expect(indexes.to_ary).to be == []
      end

      it 'removes indexes based on a block' do
        indexes << double('Index', name: 'lol')
        indexes.reject! { |index| index.name == 'lol' }
        expect(indexes.map(&:name)).not_to include 'lol'
      end
    end
  end
end
