require 'perpetuity/postgres/json_string_value'

module Perpetuity
  class Postgres
    describe JSONStringValue do
      it 'serializes into a JSON string value' do
        JSONStringValue.new('Jamie').to_s.should == '"Jamie"'
      end

      it 'converts symbols into strings' do
        JSONStringValue.new(:foo).to_s.should == '"foo"'
      end

      it 'escapes quotes' do
        JSONStringValue.new('Anakin "Darth Vader" Skywalker').to_s.should ==
          '"Anakin \\"Darth Vader\\" Skywalker"'
      end
    end
  end
end
