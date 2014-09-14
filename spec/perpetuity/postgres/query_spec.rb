require 'perpetuity/postgres/query'

module Perpetuity
  class Postgres
    describe Query do
      let(:query) { Query.new { |o| o.name == 'foo' } }

      it 'generates an equality statement' do
        expect(query.to_db).to be == "name = 'foo'"
      end

      it 'automatically converts to a string' do
        q = ''
        q << query
        expect(q).to be == "name = 'foo'"
      end

      it 'returns TRUE with no block passed' do
        expect(Query.new.to_db).to be == 'TRUE'
      end
    end
  end
end
