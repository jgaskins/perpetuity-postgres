require 'perpetuity/postgres/serializer/json_hash'

module Perpetuity
  class Postgres
    class Serializer
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
      end
    end
  end
end
