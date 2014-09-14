require 'perpetuity/postgres/boolean_value'

module Perpetuity
  class Postgres
    describe BooleanValue do
      it 'serializes true into a Postgres true value' do
        expect(BooleanValue.new(true).to_s).to be == 'TRUE'
      end

      it 'serializes false into a Postgres false value' do
        expect(BooleanValue.new(false).to_s).to be == 'FALSE'
      end
    end
  end
end
