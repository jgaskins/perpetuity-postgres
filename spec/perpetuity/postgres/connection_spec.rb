require 'perpetuity/postgres/connection'

module Perpetuity
  class Postgres
    describe Connection do
      let(:connection) { Connection.new(db: 'perpetuity_gem_test') }

      it 'sanitizes the options for the pg gem' do
        options = { db: 'db', username: 'user' }
        expect(connection.sanitize_options(options)).to be == {
          dbname: 'db',
          user: 'user'
        }
      end

      it 'is only activated when it is used' do
        expect(connection).not_to be_active
        allow(PG).to receive(:connect) { double(exec: true) }
        connection.connect
        expect(connection).to be_active
      end

      it 'executes SQL' do
        connection.execute 'CREATE TABLE IF NOT EXISTS abcdefg (name text)'
        expect(connection.tables).to include 'abcdefg'
        connection.execute 'DROP TABLE IF EXISTS abcdefg'
        expect(connection.tables).not_to include 'abcdefg'
      end
    end
  end
end
