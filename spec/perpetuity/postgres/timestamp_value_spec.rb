require 'perpetuity/postgres/timestamp_value'

module Perpetuity
  class Postgres
    describe TimestampValue do
      it 'converts to a SQL string' do
        time = Time.new(2000, 1, 2, 3, 4, 5.0123456, '-04:00')
        TimestampValue.new(time).to_s.should == "'2000-01-02 03:04:05.012345-0400'::timestamptz"
      end

      describe 'conversion from a SQL value string' do
        it 'converts GMT-X times' do
          timestamp = TimestampValue.from_sql('2013-12-01 15:31:23.838367-05')
          timestamp.to_time.should == Time.new(2013, 12, 1, 15, 31, 23.838367, '-05:00')
        end

        it 'converts GMT+X times' do
          timestamp = TimestampValue.from_sql('1982-08-25 22:19:10.123456+08')
          timestamp.to_time.should == Time.new(1982, 8, 25, 10, 19, 10.123456, '-04:00')
        end
      end

      it 'returns its wrapped value' do
        TimestampValue.new(:foo).value.should == :foo
      end
    end
  end
end
