require 'perpetuity/postgres/sql_value'

module Perpetuity
  class Postgres
    describe SQLValue do
      it 'converts strings' do
        expect(SQLValue.new('Foo')).to be == "'Foo'"
        expect(SQLValue.new("Jamie's House")).to be == "'Jamie''s House'"
      end

      it 'converts symbols' do
        expect(SQLValue.new(:foo)).to be == "'foo'"
      end

      it 'converts integers' do
        expect(SQLValue.new(1)).to be == "1"
      end

      it 'converts floats' do
        expect(SQLValue.new(1.5)).to be == "1.5"
      end

      it 'converts nil' do
        expect(SQLValue.new(nil)).to be == "NULL"
      end

      it 'converts booleans' do
        expect(SQLValue.new(true)).to be == "TRUE"
        expect(SQLValue.new(false)).to be == "FALSE"
      end

      it 'converts hashes' do
        expect(SQLValue.new({ a: 1, b: 'foo'})).to be == %q({"a":1,"b":"foo"})
      end

      it 'converts arrays' do
        expect(SQLValue.new([1, 'foo', { a: 1 }])).to be == %q([1,"foo",{"a":1}])
      end

      it 'converts JSONHashes' do
        expect(SQLValue.new(JSONHash.new(a: 1))).to be == %q({"a":1})
      end

      it 'converts JSONArrays' do
        expect(SQLValue.new(JSONArray.new([1, 'foo', [1, 'foo']]))).to be ==
          %q([1,"foo",[1,"foo"]])
      end

      it 'converts Time objects' do
        time = Time.new(2013, 1, 2, 3, 4, 5.1234567, '+05:30')
        expect(SQLValue.new(time)).to be == "'2013-01-02 03:04:05.123456+0530'::timestamptz"
      end

      it 'converts Date objects' do
        date = Date.new(2014, 8, 25)
        expect(SQLValue.new(date)).to be == "'2014-08-25'::date"
      end
    end
  end
end
