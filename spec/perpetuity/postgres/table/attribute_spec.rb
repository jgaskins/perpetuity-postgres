require 'perpetuity/postgres/table/attribute'
require 'perpetuity/postgres/expression'

module Perpetuity
  class Postgres
    class Table
      describe Attribute do
        let(:title)  { Attribute.new('title', String) }

        it 'knows its name' do
          expect(title.name).to be == 'title'
        end

        it 'knows its type' do
          expect(title.type).to be == String
        end

        describe 'id' do
          let(:id) do
            Attribute.new('id', Attribute::UUID,
                          primary_key: true,
                          default: Expression.new('uuid_generate_v4()')
                         )
          end

          it 'is a UUID type' do
            expect(id.sql_type).to be == 'UUID'
          end

          it 'is a primary key' do
            expect(id).to be_primary_key
          end

          it 'can have a specified default' do
            expect(id.default).to be == Expression.new('uuid_generate_v4()')
          end

          it 'generates the proper SQL' do
            expect(id.sql_declaration).to be == 'id UUID PRIMARY KEY DEFAULT uuid_generate_v4()'
          end
        end

        describe 'strings' do
          let(:body) { Attribute.new('body', String, default: 'foo') }

          it 'converts to the proper SQL type' do
            expect(body.sql_type).to be == 'TEXT'
          end

          it 'generates the proper SQL' do
            expect(body.sql_declaration).to be == "body TEXT DEFAULT 'foo'"
          end
        end

        describe 'integers' do
          let(:page_views) { Attribute.new('page_views', Integer, default: 0) }
          let(:public_key) { Attribute.new('public_key', Bignum) }

          it 'generates the proper SQL' do
            expect(page_views.sql_declaration).to be == 'page_views BIGINT DEFAULT 0'
            expect(public_key.sql_declaration).to be == 'public_key NUMERIC'
          end
        end

        describe 'floating-point numbers' do
          let(:pi) { Attribute.new('pi', Float) }
          let(:precise_pi) { Attribute.new('precise_pi', BigDecimal) }

          it 'generates the proper SQL' do
            expect(pi.sql_declaration).to be == 'pi FLOAT'
            expect(precise_pi.sql_declaration).to be == 'precise_pi NUMERIC'
          end
        end

        describe 'times' do
          let(:timestamp) { Attribute.new('timestamp', Time) }

          it 'converts to the SQL TIMESTAMPTZ type' do
            expect(timestamp.sql_type).to be == 'TIMESTAMPTZ'
          end
        end

        describe 'dates' do
          let(:date) { Attribute.new('anniversary_date', Date) }

          it 'converts to the SQL DATE type' do
            expect(date.sql_type).to be == 'DATE'
          end
        end

        describe 'booleans' do
          it 'is stored in a BOOLEAN column' do
            expect(Attribute.new(:true,  TrueClass).sql_type).to be == 'BOOLEAN'
            expect(Attribute.new(:false, FalseClass).sql_type).to be == 'BOOLEAN'
          end
        end

        describe 'non-serializable types' do
          let(:author) { Attribute.new('author', Object) }

          it 'has an SQL type of JSON' do
            expect(author.sql_type).to be == 'JSON'
          end
        end
      end
    end
  end
end
