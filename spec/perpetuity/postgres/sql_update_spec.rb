require 'perpetuity/postgres/sql_update'

module Perpetuity
  class Postgres
    describe SQLUpdate do
      it 'generates the SQL to update an object' do
        update = SQLUpdate.new('User', 123, foo: 'bar', baz: 'quux')
        update.to_s.should == %Q{UPDATE "User" SET foo = 'bar',baz = 'quux' WHERE id = 123}

      end
    end
  end
end
