require 'perpetuity/postgres/sql_select'

module Perpetuity
  class Postgres
    describe SQLSelect do
      let(:query) { SQLSelect.new(from: 'foo',
                                  where: "name = 'foo'",
                                  limit: 4) }
      subject { query }

      it 'returns its table name' do
        expect(query.table).to be == 'foo'
      end

      it 'returns its WHERE clause' do
        expect(query.where).to be == "name = 'foo'"
      end

      it 'returns its limit' do
        expect(query.limit).to be == 4
      end

      it 'generates a SQL query' do
        expect(query.to_s).to be == %Q{SELECT * FROM "foo" WHERE name = 'foo' LIMIT 4}
      end

      it 'generates a query with no clauses' do
        sql = SQLSelect.new(from: 'foo').to_s
        expect(sql).to be == %Q{SELECT * FROM "foo"}
      end

      it 'generates a count query' do
        sql = SQLSelect.new('COUNT(*)', from: 'foo').to_s
        expect(sql).to be == %Q{SELECT COUNT(*) FROM "foo"}
      end

      it 'generates a query with an ORDER BY clause' do
        sql = SQLSelect.new(from: 'foo', order: 'name').to_s
        expect(sql).to be == %Q{SELECT * FROM "foo" ORDER BY name}

        sql = SQLSelect.new(from: 'foo', order: { name: :asc }).to_s
        expect(sql).to be == %Q{SELECT * FROM "foo" ORDER BY name ASC}

        sql = SQLSelect.new(from: 'foo', order: { name: :asc, age: :desc }).to_s
        expect(sql).to be == %Q{SELECT * FROM "foo" ORDER BY name ASC,age DESC}
      end

      it 'generates a query with an OFFSET clause' do
        sql = SQLSelect.new(from: 'foo', offset: 12).to_s
        expect(sql).to be == %Q{SELECT * FROM "foo" OFFSET 12}
      end

      it 'generates a query with a GROUP BY clause' do
        sql = SQLSelect.new(from: 'foo', group: :id).to_s
        expect(sql).to be == %Q{SELECT * FROM "foo" GROUP BY id}
      end
    end
  end
end
