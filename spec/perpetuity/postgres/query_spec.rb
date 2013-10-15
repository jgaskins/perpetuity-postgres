require 'perpetuity/postgres/query'

module Perpetuity
  class Postgres
    describe Query do
      it 'generates an equality statement' do
        query = Query.new { |o| o.name == 'foo' }
        query.to_db.should == "name = 'foo'"
      end
    end
  end
end
