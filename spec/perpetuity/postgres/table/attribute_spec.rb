require 'perpetuity/postgres/table/attribute'
require 'perpetuity/postgres/expression'

module Perpetuity
  class Postgres
    class Table
      describe Attribute do
        let(:title)  { Attribute.new('title', String) }

        it 'knows its name' do
          title.name.should == 'title'
        end

        it 'knows its type' do
          title.type.should == String
        end

        describe 'id' do
          let(:id) do
            Attribute.new('id', Attribute::UUID,
                          primary_key: true,
                          default: Expression.new('uuid_generate_v4()')
                         )
          end

          it 'is a UUID type' do
            id.sql_type.should == 'UUID'
          end

          it 'is a primary key' do
            id.should be_primary_key
          end

          it 'can have a specified default' do
            id.default.should == Expression.new('uuid_generate_v4()')
          end

          it 'generates the proper SQL' do
            id.sql_declaration.should == 'id UUID PRIMARY KEY DEFAULT uuid_generate_v4()'
          end
        end

        describe 'strings' do
          let(:body) { Attribute.new('body', String, default: 'foo') }

          it 'converts to the proper SQL type' do
            body.sql_type.should == 'TEXT'
          end

          it 'generates the proper SQL' do
            body.sql_declaration.should == "body TEXT DEFAULT 'foo'"
          end
        end

        describe 'integers' do
          let(:page_views) { Attribute.new('page_views', Integer, default: 0) }
          let(:public_key) { Attribute.new('public_key', Bignum) }

          it 'generates the proper SQL' do
            page_views.sql_declaration.should == 'page_views BIGINT DEFAULT 0'
            public_key.sql_declaration.should == 'public_key NUMERIC'
          end
        end

        describe 'floating-point numbers' do
          let(:pi) { Attribute.new('pi', Float) }
          let(:precise_pi) { Attribute.new('precise_pi', BigDecimal) }

          it 'generates the proper SQL' do
            pi.sql_declaration.should == 'pi FLOAT'
            precise_pi.sql_declaration.should == 'precise_pi NUMERIC'
          end
        end

        describe 'times' do
          let(:timestamp) { Attribute.new('timestamp', Time) }

          it 'converts to the SQL TIMESTAMPTZ type' do
            timestamp.sql_type.should == 'TIMESTAMPTZ'
          end
        end

        describe 'dates' do
          let(:date) { Attribute.new('anniversary_date', Date) }

          it 'converts to the SQL DATE type' do
            date.sql_type.should == 'DATE'
          end
        end

        describe 'booleans' do
          it 'is stored in a BOOLEAN column' do
            Attribute.new(:true,  TrueClass).sql_type.should == 'BOOLEAN'
            Attribute.new(:false, FalseClass).sql_type.should == 'BOOLEAN'
          end
        end

        describe 'non-serializable types' do
          let(:author) { Attribute.new('author', Object) }

          it 'has an SQL type of JSON' do
            author.sql_type.should == 'JSON'
          end
        end
      end
    end
  end
end
