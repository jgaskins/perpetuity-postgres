require 'perpetuity/postgres/serializer/numeric_value'

module Perpetuity
  class Postgres
    class Serializer
      describe NumericValue do
        it 'serializes into a Postgres-compatible number value' do
          NumericValue.new(1).to_s.should == '1'
        end
      end
    end
  end
end

