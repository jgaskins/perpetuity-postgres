require 'perpetuity/postgres/connection_pool'

module Perpetuity
  class Postgres
    describe ConnectionPool do
      let(:pool) { ConnectionPool.new }

      it 'defaults to 5 connections' do
        expect(pool.connections.size).to eq 5
      end

      describe 'lending a connection' do
        it 'executes the given block' do
          expect { |probe| pool.lend_connection(&probe) }.to yield_control
        end

        it 'does not yield when there is no block given' do
          pool.lend_connection
        end

        it 'lends a connection for the duration of a block' do
          pool.lend_connection do |connection|
            expect(pool.connections.size).to eq 4
          end
          expect(pool.connections.size).to eq 5
        end

        it 'returns the value of the block' do
          expect(pool.lend_connection { 1 }).to be == 1
        end
      end

      it 'executes a given SQL statement' do
        sql = "SELECT TRUE"
        expect_any_instance_of(Connection).to receive(:execute).with(sql)
        pool.execute sql
      end

      it 'passes the tables message to a connection' do
        expect_any_instance_of(Connection).to receive(:tables)
        pool.tables
      end

      it 'cycles through each connection round-robin style' do
        connections = []
        pool.size.times do
          pool.lend_connection { |c| connections << c }
        end

        expect(connections.uniq.size).to eq pool.size
      end
    end
  end
end
