require 'perpetuity/postgres/sql_update'
require 'perpetuity/postgres/serialized_data'

module Perpetuity
  class Postgres
    describe SQLUpdate do
      context 'when given a SerializedData' do
        it 'generates the SQL to update an object' do
          update = SQLUpdate.new('User', 'abc123', SerializedData.new([:foo, :baz], ["'bar'", "'quux'"]))
          expect(update.to_s).to be == %Q{UPDATE "User" SET foo = 'bar',baz = 'quux' WHERE id = 'abc123'}
        end
      end

      context 'when given a hash' do
        it 'sanitizes the data into SQLValues' do
          update = SQLUpdate.new('User', 'abc123', foo: 'bar', baz: 'quux')
          expect(update.to_s).to be == %Q{UPDATE "User" SET foo = 'bar',baz = 'quux' WHERE id = 'abc123'}
        end
      end
    end
  end
end
