require 'perpetuity/postgres/query_attribute'

module Perpetuity
  class Postgres
    describe QueryAttribute do
      let(:attribute) { QueryAttribute.new :attribute_name }

      it 'returns its name' do
        attribute.name.should == :attribute_name
      end

      it 'checks for equality' do
        (attribute == 1).should be_a QueryExpression
      end

      it 'checks for less than' do
        (attribute < 1).should be_a QueryExpression
      end

      it 'checks for <=' do
        (attribute <= 1).should be_a QueryExpression
      end

      it 'checks for greater than' do
        (attribute > 1).should be_a QueryExpression
      end

      it 'checks for >=' do
        (attribute >= 1).should be_a QueryExpression
      end

      it 'checks for inequality' do
        (attribute != 1).should be_a QueryExpression
      end

      it 'checks for regexp matches' do
        (attribute =~ /value/).should be_a QueryExpression
      end

      it 'checks for inclusion' do
        (attribute.in [1, 2, 3]).should be_a QueryExpression
      end

      it 'checks for existence' do
        (attribute.any?).to_db.should == 'json_array_length(attribute_name) > 0'
      end

      it 'checks for no existence' do
        (attribute.none?).to_db.should == 'json_array_length(attribute_name) = 0'
      end

      it 'checks for nil' do
        attribute.nil?.should be_a QueryExpression
      end

      it 'checks for truthiness' do
        attribute.to_db.should == 'attribute_name IS NOT NULL'
      end

      describe 'nested attributes' do
        it 'checks for an id' do
          id = attribute.id
          id.should be_a QueryAttribute
          id.name.should == %q{attribute_name->'__metadata__'->>'id'}
        end
      end
    end
  end
end
