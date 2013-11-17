require 'perpetuity/postgres/query'

module Perpetuity
  class Postgres
    describe Query do
      let(:query) { Query.new { |o| o.name == 'foo' } }

      it 'generates an equality statement' do
        query.to_db.should == "name = 'foo'"
      end

      it 'automatically converts to a string' do
        q = ''
        q << query
        q.should == "name = 'foo'"
      end

      it 'returns TRUE with no block passed' do
        Query.new.to_db.should == 'TRUE'
      end
    end
  end
end
