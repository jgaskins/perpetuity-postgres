require 'perpetuity/postgres/value_with_attribute'
require 'ostruct'

module Perpetuity
  class Postgres
    describe ValueWithAttribute do
      let(:attribute) { OpenStruct.new(name: :name, type: String) }
      let(:serialized) { ValueWithAttribute.new('foo', attribute) }

      it 'contains a value and an attribute' do
        expect(serialized.value).to be == 'foo'
        expect(serialized.attribute).to be == attribute
      end

      it 'knows its type' do
        expect(serialized.type).to be String
      end

      context 'when attribute is embedded' do
        let(:attribute) { OpenStruct.new(embedded?: true) }
        it 'is embedded' do
          expect(serialized).to be_embedded
        end
      end

      context 'when attribute is not embedded' do
        let(:attribute) { OpenStruct.new(embedded?: false) }

        it 'is not embedded' do
          expect(serialized).not_to be_embedded
        end
      end

      it 'passes messages to the value' do
        expect(serialized.upcase).to be == 'FOO'
      end
    end
  end
end
