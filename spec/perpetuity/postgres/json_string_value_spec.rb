require 'perpetuity/postgres/json_string_value'

module Perpetuity
  class Postgres
    describe JSONStringValue do
      it 'serializes into a JSON string value' do
        expect(JSONStringValue.new('Jamie').to_s).to be == '"Jamie"'
      end

      it 'converts symbols into strings' do
        expect(JSONStringValue.new(:foo).to_s).to be == '"foo"'
      end

      it 'escapes quotes' do
        expect(JSONStringValue.new('Anakin "Darth Vader" Skywalker').to_s).to be ==
          '"Anakin \\"Darth Vader\\" Skywalker"'
      end

      it 'escapes single quotes' do
        expect(JSONStringValue.new(%{Man it's a hot one}).to_s).to be ==
          %{"Man it''s a hot one"}
      end
    end
  end
end
