require 'perpetuity/postgres/json_hash'

module Perpetuity
  class Postgres
    describe JSONHash do
      it 'serializes empty hashes' do
        JSONHash.new({}).to_s.should == "'{}'"
      end

      it 'serializes hashes with string elements' do
        JSONHash.new({a: 'b'}).to_s.should == %q{'{"a":"b"}'}
      end

      it 'serializes hashes with numeric elements' do
        JSONHash.new({a: 1}).to_s.should == %q{'{"a":1}'}
      end

      it 'serializes hashes with boolean elements' do
        JSONHash.new({a: true, b: false}).to_s.should == %q('{"a":true,"b":false}')
      end

      it 'serializes nil values' do
        JSONHash.new({a: nil}).to_s.should == %q('{"a":null}')
      end

      it 'does not surround the an inner serialized value with quotes' do
        JSONHash.new({a: 1}, :inner).to_s.should == %q[{"a":1}]
      end

      it 'serializes hashes with multiple entries' do
        JSONHash.new({a: 1, b: 'c'}).to_s.should == %q{'{"a":1,"b":"c"}'}
      end

      it 'serializes a hash with array values' do
        JSONHash.new({foo: ['bar', 'baz', 'quux']}).to_s.should ==
          %q{'{"foo":["bar","baz","quux"]}'}
      end

      it 'converts back to a hash' do
        JSONHash.new({a: 1}).to_hash.should == { a: 1 }
      end

      it 'is equal to an identical hash' do
        JSONHash.new(a: 1).should == JSONHash.new(a: 1)
      end
    end
  end
end
