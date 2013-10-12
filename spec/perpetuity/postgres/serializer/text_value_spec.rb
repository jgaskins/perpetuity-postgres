require 'perpetuity/postgres/serializer/text_value'

module Perpetuity
  class Postgres
    class Serializer
      describe TextValue do
        it 'serializes into a Postgres-compatible string' do
          TextValue.new('Jamie').to_s.should == "'Jamie'"
        end
      end
    end
  end
end
