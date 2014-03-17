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

      describe 'adding values' do
        it 'adds a value' do
          serialized['id'] = 'abc'
          serialized.to_s.should == "(name,age,id) VALUES ('Jamie',31,'abc')"
        end

        it 'replaces an existing value' do
          serialized['id'] = 'abc'
          serialized['id'] = 'xyz'
          serialized.to_s.should == "(name,age,id) VALUES ('Jamie',31,'xyz')"
        end
      end

      context 'with multiple serialized objects' do
        let(:serialized_multiple) do
          [ SerializedData.new(columns, ["'Jamie'", 31]),
            SerializedData.new(columns, ["'Jessica'", 23]),
            SerializedData.new(columns, ["'Kevin'", 22]),
          ]
        end

        it 'matches a SQL string' do
          serialized_multiple.reduce(:+).to_s.should ==
            "(name,age) VALUES ('Jamie',31),('Jessica',23),('Kevin',22)"
        end

        it 'does not modify the first value' do
          jamie_values = serialized_multiple.first.values.dup
          serialized_multiple.reduce(:+)
          serialized_multiple.first.values.should == jamie_values
        end
      end

      it 'checks whether there are any objects' do
        serialized.any?.should be_true
        serialized.values.clear << []
        serialized.any?.should be_false
      end

      it 'iterates like a hash' do
        serialized.map { |attr, value| [attr, value] }.should ==
          [['name', "'Jamie'"], ['age', 31]]
      end

      it 'accesses values like a hash' do
        serialized['age'].should == 31
        serialized[:age].should == 31
      end

      it 'equals another with the same data' do
        original = SerializedData.new([:a, :b], [1, 2])
        duplicate = SerializedData.new([:a, :b], [1, 2])
        modified = SerializedData.new([:a, :b], [0, 2])
        original.should == duplicate
        original.should_not == modified
      end

      it 'returns a new SerializedData with the complement of values' do
        columns = [:name, :age, :foo, :bar]
        original = SerializedData.new(columns, ["'Jamie'", 31, nil, nil])
        new_name = SerializedData.new(columns, ["'Foo'", 31, nil, nil])
        new_age = SerializedData.new(columns, ["'Jamie'", 32, nil, nil])
        (new_name - original).should == SerializedData.new([:name], ["'Foo'"])
        (new_age - original).should == SerializedData.new([:age], [32])
      end
    end
  end
end
