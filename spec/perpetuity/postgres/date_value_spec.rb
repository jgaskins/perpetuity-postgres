require 'perpetuity/postgres/date_value'

module Perpetuity
  class Postgres
    describe DateValue do
      it 'converts to a SQL string' do
        date = Date.new(2014, 8, 25)
        expect(DateValue.new(date).to_s).to be == "'2014-08-25'::date"
      end

      describe 'conversion from a SQL value string' do
        it 'converts GMT-X times' do
          actual = DateValue.from_sql('2013-12-01')
          expected = Date.new(2013, 12, 1)
          expect(actual.to_date).to be == expected
        end
      end

      it 'returns its wrapped value' do
        expect(DateValue.new(:foo).value).to be == :foo
      end
    end
  end
end
