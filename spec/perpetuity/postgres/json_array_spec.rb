require 'perpetuity/postgres/json_array'

module Perpetuity
  class Postgres
    describe JSONArray do
      it 'serializes empty arrays' do
        expect(JSONArray.new([]).to_s).to be == "'[]'"
      end

      it 'serializes arrays of numeric values' do
        expect(JSONArray.new([1,2,3]).to_s).to be == "'[1,2,3]'"
      end

      it 'serializes arrays of strings' do
        expect(JSONArray.new(%w(foo bar baz)).to_s).to be == %q{'["foo","bar","baz"]'}
      end

      it 'serializes arrays of hashes' do
        expect(JSONArray.new([{a: 1}, {b: 2}]).to_s).to be == %q{'[{"a":1},{"b":2}]'}
      end

      it 'serializes arrays of JSONHashes' do
        expect(JSONArray.new([JSONHash.new(a: 1)]).to_s).to be == %q{'[{"a":1}]'}
      end

      it 'serializes arrays of arrays' do
        expect(JSONArray.new([[1], ['foo']]).to_s).to be == %q{'[[1],["foo"]]'}
      end

      it 'serializes elements of arrays' do
        expect(JSONArray.new([1,'a']).to_s).to be == %q{'[1,"a"]'}
      end
    end
  end
end
