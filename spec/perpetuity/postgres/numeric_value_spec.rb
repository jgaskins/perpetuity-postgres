require 'perpetuity/postgres/numeric_value'

module Perpetuity
  class Postgres
    describe NumericValue do
      it 'serializes into a Postgres-compatible number value' do
        expect(NumericValue.new(1).to_s).to be == '1'
      end
    end
  end
end

