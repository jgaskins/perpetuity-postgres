require 'perpetuity/postgres/table'
require 'perpetuity/postgres/table/attribute'

module Perpetuity
  class Postgres
    describe Table do
      let(:title)  { Table::Attribute.new('title', String, max_length: 40) }
      let(:body)   { Table::Attribute.new('body', String) }
      let(:author) { Table::Attribute.new('author', Object) }
      let(:published_at) { Table::Attribute.new('published_at', Time) }
      let(:views) { Table::Attribute.new('views', Integer) }
      let(:attributes) { [title, body, author, published_at, views] }
      let(:table) { Table.new('Article', attributes) }

      it 'knows its name' do
        table.name.should == 'Article'
      end

      it 'knows its attributes' do
        table.attributes.should == attributes
      end

      it 'converts to a string for SQL' do
        table.to_s.should == '"Article"'
      end

      it 'generates proper SQL to create itself' do
        table.create_table_sql.should ==
          'CREATE TABLE IF NOT EXISTS "Article" (id UUID PRIMARY KEY DEFAULT uuid_generate_v4(), title TEXT, body TEXT, author JSON, published_at TIMESTAMPTZ, views BIGINT)'
      end

      it 'sets the id as PRIMARY KEY even if specified in attributes' do
        attributes = self.attributes.dup
        attributes.unshift Table::Attribute.new(:id, String)
        table = Table.new('Article', attributes)
        table.create_table_sql.should ==
          'CREATE TABLE IF NOT EXISTS "Article" (id TEXT PRIMARY KEY, title TEXT, body TEXT, author JSON, published_at TIMESTAMPTZ, views BIGINT)'
      end

      describe 'id column' do
        context 'when there is an id attribute' do
          it 'uses the attribute type for the column type' do
            attributes = [Table::Attribute.new(:id, String, primary_key: true), Table::Attribute.new(:name, String)]
            table = Table.new('User', attributes)
            table.create_table_sql.should == 'CREATE TABLE IF NOT EXISTS "User" (id TEXT PRIMARY KEY, name TEXT)'
          end
        end
      end
    end
  end
end
