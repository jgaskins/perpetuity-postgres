require 'perpetuity/postgres/serialized_data'

module Perpetuity
  class Postgres
    describe SerializedData do
      let(:columns) { [:name, :age] }
      let(:data) { ["'Jamie'", 31] }
      let(:serialized) { SerializedData.new(columns, data) }

      it 'matches a SQL string' do
        serialized.to_s.should == "(name,age) VALUES ('Jamie',31)"
      end

      it 'adds a value' do
        serialized['id'] = 'abc'
        serialized.to_s.should == "(name,age,id) VALUES ('Jamie',31,'abc')"
      end

      context 'with multiple serialized objects' do
        let(:serialized_multiple) do
          [ SerializedData.new(columns, ["'Jamie'", 31]),
            SerializedData.new(columns, ["'Jessica'", 23]),
            SerializedData.new(columns, ["'Kevin'", 22]),
          ].reduce(:+)
        end
        let(:serialized_multiple) { serialized + SerializedData.new(columns, ["'Jessica'", 23]) +
                                                 SerializedData.new(columns, ["'Kevin'",22])}

        it 'matches a SQL string' do
          serialized_multiple.to_s.should == "(name,age) VALUES ('Jamie',31),('Jessica',23),('Kevin',22)"
        end
      end
    end
  end
end
