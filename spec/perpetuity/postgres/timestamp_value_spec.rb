require 'perpetuity/postgres/timestamp_value'

module Perpetuity
  class Postgres
    describe TimestampValue do
      it 'converts to a SQL string' do
        time = Time.new(2000, 1, 2, 3, 4, 5.0123456, '-04:00')
        expect(TimestampValue.new(time).to_s).to be == "'2000-01-02 03:04:05.012345-0400'::timestamptz"
      end

      describe 'conversion from a SQL value string' do
        it 'converts GMT-X times' do
          actual = TimestampValue.from_sql('2013-12-01 15:31:23.838367-05')
          expected = Time.new(2013, 12, 1, 15, 31, 23.838367, '-05:00')
          expect(actual.to_time).to be_within(0.0000001).of expected
        end

        it 'converts GMT+X times' do
          actual = TimestampValue.from_sql('1982-08-25 22:19:10.123456+08')
          expected = Time.new(1982, 8, 25, 10, 19, 10.123456, '-04:00')
          expect(actual.to_time).to be_within(0.0000001).of expected
        end
      end

      it 'returns its wrapped value' do
        expect(TimestampValue.new(:foo).value).to be == :foo
      end
    end
  end
end
