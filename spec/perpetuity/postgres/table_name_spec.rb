require 'perpetuity/postgres/table_name'

module Perpetuity
  class Postgres
    describe TableName do
      it 'converts to a SQL-string table name' do
        TableName.new('Person').to_s.should == '"Person"'
      end

      it 'compares equally to its string representation' do
        TableName.new('Person').should == 'Person'
      end
    end
  end
end
