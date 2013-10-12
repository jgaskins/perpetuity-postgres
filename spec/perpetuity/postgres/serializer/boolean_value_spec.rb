require 'perpetuity/postgres/serializer/boolean_value'

module Perpetuity
  class Postgres
    class Serializer
      describe BooleanValue do
        it 'serializes true into a Postgres true value' do
          BooleanValue.new(true).to_s.should == 'TRUE'
        end

        it 'serializes false into a Postgres false value' do
          BooleanValue.new(false).to_s.should == 'FALSE'
        end
      end
    end
  end
end
