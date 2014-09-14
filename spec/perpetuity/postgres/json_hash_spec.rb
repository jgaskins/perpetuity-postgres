require 'perpetuity/postgres/json_hash'

module Perpetuity
  class Postgres
    describe JSONHash do
      it 'serializes empty hashes' do
        expect(JSONHash.new({}).to_s).to be == "'{}'"
      end

      it 'serializes hashes with string elements' do
        expect(JSONHash.new({a: 'b'}).to_s).to be == %q{'{"a":"b"}'}
      end

      it 'serializes hashes with numeric elements' do
        expect(JSONHash.new({a: 1}).to_s).to be == %q{'{"a":1}'}
      end

      it 'serializes hashes with boolean elements' do
        expect(JSONHash.new({a: true, b: false}).to_s).to be == %q('{"a":true,"b":false}')
      end

      it 'serializes nil values' do
        expect(JSONHash.new({a: nil}).to_s).to be == %q('{"a":null}')
      end

      it 'does not surround the an inner serialized value with quotes' do
        expect(JSONHash.new({a: 1}, :inner).to_s).to be == %q[{"a":1}]
      end

      it 'serializes hashes with multiple entries' do
        expect(JSONHash.new({a: 1, b: 'c'}).to_s).to be == %q{'{"a":1,"b":"c"}'}
      end

      it 'serializes a hash with array values' do
        expect(JSONHash.new({foo: ['bar', 'baz', 'quux']}).to_s).to be ==
          %q{'{"foo":["bar","baz","quux"]}'}
      end

      it 'converts back to a hash' do
        expect(JSONHash.new({a: 1}).to_hash).to be == { a: 1 }
      end

      it 'is equal to an identical hash' do
        expect(JSONHash.new(a: 1)).to be == JSONHash.new(a: 1)
      end
    end
  end
end
