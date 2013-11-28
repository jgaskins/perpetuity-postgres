require 'perpetuity/postgres/numeric_value'

module Perpetuity
  class Postgres
    describe NumericValue do
      it 'serializes into a Postgres-compatible number value' do
        NumericValue.new(1).to_s.should == '1'
      end
    end
  end
end

