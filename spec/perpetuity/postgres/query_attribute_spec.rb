require 'perpetuity/postgres/query_attribute'

module Perpetuity
  class Postgres
    describe QueryAttribute do
      let(:attribute) { QueryAttribute.new :attribute_name }

      it 'returns its name' do
        expect(attribute.name).to be == :attribute_name
      end

      it 'checks for equality' do
        expect((attribute == 1)).to be_a QueryExpression
      end

      it 'checks for less than' do
        expect((attribute < 1)).to be_a QueryExpression
      end

      it 'checks for <=' do
        expect((attribute <= 1)).to be_a QueryExpression
      end

      it 'checks for greater than' do
        expect((attribute > 1)).to be_a QueryExpression
      end

      it 'checks for >=' do
        expect((attribute >= 1)).to be_a QueryExpression
      end

      it 'checks for inequality' do
        expect((attribute != 1)).to be_a QueryExpression
      end

      it 'checks for regexp matches' do
        expect((attribute =~ /value/)).to be_a QueryExpression
      end

      it 'checks for inclusion' do
        expect((attribute.in [1, 2, 3])).to be_a QueryExpression
      end

      it 'checks for existence' do
        expect((attribute.any?).to_db).to be == 'json_array_length(attribute_name) > 0'
      end

      it 'checks for no existence' do
        expect((attribute.none?).to_db).to be == 'json_array_length(attribute_name) = 0'
      end

      it 'checks for nil' do
        expect(attribute.nil?).to be_a QueryExpression
      end

      it 'checks for truthiness' do
        expect(attribute.to_db).to be == 'attribute_name IS NOT NULL'
      end

      describe 'nested attributes' do
        it 'checks for an id' do
          id = attribute.id
          expect(id).to be_a QueryAttribute
          expect(id.name).to be == %q{attribute_name->'__metadata__'->>'id'}
        end
      end
    end
  end
end
