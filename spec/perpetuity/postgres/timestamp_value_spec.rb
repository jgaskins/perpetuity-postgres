require 'perpetuity/postgres/timestamp_value'

module Perpetuity
  class Postgres
    describe TimestampValue do
      it 'converts to a SQL string' do
        time = Time.new(2000, 1, 2, 3, 4, 5.0123456, '-04:00')
        TimestampValue.new(time).to_s.should == "'2000-01-02 03:04:05.012345-0400'::timestamptz"
      end
    end
  end
end
