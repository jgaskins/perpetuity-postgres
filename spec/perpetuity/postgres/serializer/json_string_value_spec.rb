require 'perpetuity/postgres/serializer/json_string_value'

module Perpetuity
  class Postgres
    class Serializer
      describe JSONStringValue do
        it 'serializes into a JSON string value' do
          JSONStringValue.new('Jamie').to_s.should == '"Jamie"'
        end
      end
    end
  end
end
