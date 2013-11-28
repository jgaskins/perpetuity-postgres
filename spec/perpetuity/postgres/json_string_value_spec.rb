require 'perpetuity/postgres/json_string_value'

module Perpetuity
  class Postgres
    describe JSONStringValue do
      it 'serializes into a JSON string value' do
        JSONStringValue.new('Jamie').to_s.should == '"Jamie"'
      end
    end
  end
end
