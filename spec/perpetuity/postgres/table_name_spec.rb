require 'perpetuity/postgres/table_name'

module Perpetuity
  class Postgres
    describe TableName do
      it 'converts to a SQL-string table name' do
        expect(TableName.new('Person').to_s).to be == '"Person"'
      end

      it 'cannot contain double quotes' do
        expect { TableName.new('Foo "Bar"') }.to raise_error InvalidTableName
      end

      it 'compares equally to its string representation' do
        expect(TableName.new('Person')).to be == 'Person'
      end
    end
  end
end
