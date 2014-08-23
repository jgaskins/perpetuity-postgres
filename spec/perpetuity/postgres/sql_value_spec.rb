require 'perpetuity/postgres/sql_value'

module Perpetuity
  class Postgres
    describe SQLValue do
      it 'converts strings' do
        SQLValue.new('Foo').should == "'Foo'"
        SQLValue.new("Jamie's House").should == "'Jamie''s House'"
      end

      it 'converts symbols' do
        SQLValue.new(:foo).should == "'foo'"
      end

      it 'converts integers' do
        SQLValue.new(1).should == "1"
      end

      it 'converts floats' do
        SQLValue.new(1.5).should == "1.5"
      end

      it 'converts nil' do
        SQLValue.new(nil).should == "NULL"
      end

      it 'converts booleans' do
        SQLValue.new(true).should == "TRUE"
        SQLValue.new(false).should == "FALSE"
      end

      it 'converts hashes' do
        SQLValue.new({ a: 1, b: 'foo'}).should == %q({"a":1,"b":"foo"})
      end

      it 'converts arrays' do
        SQLValue.new([1, 'foo', { a: 1 }]).should == %q([1,"foo",{"a":1}])
      end

      it 'converts JSONHashes' do
        SQLValue.new(JSONHash.new(a: 1)).should == %q({"a":1})
      end

      it 'converts JSONArrays' do
        SQLValue.new(JSONArray.new([1, 'foo', [1, 'foo']])).should ==
          %q([1,"foo",[1,"foo"]])
      end

      it 'converts Time objects' do
        time = Time.new(2013, 1, 2, 3, 4, 5.1234567, '+05:30')
        SQLValue.new(time).should == "'2013-01-02 03:04:05.123456+0530'::timestamptz"
      end

      it 'converts Date objects' do
        date = Date.new(2014, 8, 25)
        SQLValue.new(date).should == "'2014-08-25'::date"
      end
    end
  end
end
