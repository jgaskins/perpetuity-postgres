require 'perpetuity/postgres/value_with_attribute'

module Perpetuity
  class Postgres
    describe ValueWithAttribute do
      let(:attribute) { OpenStruct.new(name: :name, type: String) }
      let(:serialized) { ValueWithAttribute.new('foo', attribute) }

      it 'contains a value and an attribute' do
        serialized.value.should == 'foo'
        serialized.attribute.should == attribute
      end

      it 'knows its type' do
        serialized.type.should be String
      end

      context 'when attribute is embedded' do
        let(:attribute) { OpenStruct.new(embedded?: true) }
        it 'is embedded' do
          serialized.should be_embedded
        end
      end

      context 'when attribute is not embedded' do
        let(:attribute) { OpenStruct.new(embedded?: false) }

        it 'is not embedded' do
          serialized.should_not be_embedded
        end
      end
    end
  end
end
