require 'perpetuity/postgres/sql_select'

module Perpetuity
  class Postgres
    describe SQLSelect do
      let(:query) { SQLSelect.new(from: 'foo',
                                  where: "name = 'foo'",
                                  limit: 4) }
      subject { query }

      its(:table) { should == 'foo' }
      its(:where) { should == "name = 'foo'" }
      its(:limit) { should == 4 }

      it 'generates a SQL query' do
        query.to_s.should == %Q{SELECT * FROM "foo" WHERE name = 'foo' LIMIT 4}
      end

      it 'generates a query with no clauses' do
        sql = SQLSelect.new(from: 'foo').to_s
        sql.should == %Q{SELECT * FROM "foo"}
      end

      it 'generates a count query' do
        sql = SQLSelect.new('COUNT(*)', from: 'foo').to_s
        sql.should == %Q{SELECT COUNT(*) FROM "foo"}
      end
    end
  end
end
