require 'perpetuity/postgres/serializer/null_value'

module Perpetuity
  class Postgres
    class Serializer
      describe NullValue do
        it 'serializes into a Postgress NULL value' do
          NullValue.new.to_s.should == 'NULL'
        end
      end
    end
  end
end
