require 'perpetuity/postgres/null_value'

module Perpetuity
  class Postgres
    describe NullValue do
      it 'serializes into a Postgres NULL value' do
        expect(NullValue.new.to_s).to be == 'NULL'
      end
    end
  end
end
