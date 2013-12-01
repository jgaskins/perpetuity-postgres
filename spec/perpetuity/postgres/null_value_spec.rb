require 'perpetuity/postgres/null_value'

module Perpetuity
  class Postgres
    describe NullValue do
      it 'serializes into a Postgres NULL value' do
        NullValue.new.to_s.should == 'NULL'
      end
    end
  end
end
