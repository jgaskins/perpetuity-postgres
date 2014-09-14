require 'perpetuity/postgres'
require 'perpetuity/postgres/table/attribute'
require 'perpetuity/attribute'
require 'perpetuity/postgres/serialized_data'

module Perpetuity
  describe Postgres do
    let(:postgres) { Postgres.new(db: 'perpetuity_gem_test') }

    describe 'initialization params' do
      context 'with params' do
        let(:host)      { double('host') }
        let(:port)      { double('port') }
        let(:db)        { double('db') }
        let(:pool_size) { 5 }
        let(:username)  { double('username') }
        let(:password)  { double('password') }
        let(:postgres) do
          Postgres.new(
            host:      host,
            port:      port,
            db:        db,
            pool_size: pool_size,
            username:  username,
            password:  password
          )
        end

        [:host, :port, :db, :pool_size, :username, :password].each do |attribute|
          it "returns its #{attribute}" do
            expect(postgres.public_send(attribute)).to be == send(attribute)
          end
        end
      end

      context 'default values' do
        let(:postgres) { Postgres.new(db: 'my_db') }

        it 'defaults to host = localhost' do
          expect(postgres.host).to be == 'localhost'
        end

        it 'defaults to port = 5432 (Postgres default)' do
          expect(postgres.port).to be == 5432
        end

        it "defaults to username = #{ENV['USER']}" do
          expect(postgres.username).to be == ENV['USER']
        end

        it 'defaults to a blank password' do
          expect(postgres.password).to be nil
        end

        it 'defaults to pool_size = 5' do
          expect(postgres.pool_size).to be == 5
        end
      end
    end

    it 'creates and drops tables' do
      postgres.create_table 'Article', [
        Postgres::Table::Attribute.new('title', String, max_length: 40),
        Postgres::Table::Attribute.new('body', String),
        Postgres::Table::Attribute.new('author', Object)
      ]
      expect(postgres).to have_table('Article')

      postgres.drop_table 'Article'
      expect(postgres).not_to have_table 'Article'
    end

    it 'adds columns automatically if they are not there' do
      attributes = AttributeSet.new
      attributes << Attribute.new('title', String, max_length: 40)
      attributes << Attribute.new('body', String)
      attributes << Attribute.new('author', Object)

      postgres.drop_table 'Article'
      postgres.create_table 'Article', attributes.map { |attr|
        Postgres::Table::Attribute.new(attr.name, attr.type, attr.options)
      }

      attributes << Attribute.new('timestamp', Time)
      data = [Postgres::SerializedData.new([:title, :timestamp],
                                           ["'Jamie'", "'2013-1-1'"])]
      id = postgres.insert('Article', data, attributes).first

      expect(postgres.find('Article', id)['timestamp']).to be =~ /2013/

      postgres.drop_table 'Article' # Cleanup
    end

    it 'converts values into something that works with the DB' do
      expect(postgres.postgresify("string")).to be == "'string'"
      expect(postgres.postgresify(1)).to be == '1'
      expect(postgres.postgresify(true)).to be == 'TRUE'
    end

    describe 'working with data' do
      let(:attributes) { AttributeSet.new }
      let(:data) { [Postgres::SerializedData.new([:name], ["'Jamie'"])] }

      before do
        attributes << Attribute.new(:name, String)
      end

      it 'inserts data and finds by id' do
        id = postgres.insert('User', data, attributes).first
        result = postgres.find('User', id)

        expect(id).to be =~ /[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}/
        expect(result['name']).to be == 'Jamie'
      end

      describe 'returning ids' do
        it 'returns the ids of all items saved' do
          data << Postgres::SerializedData.new([:name], ["'Jessica'"]) <<
          Postgres::SerializedData.new([:name], ["'Kevin'"])
          ids = postgres.insert('User', data, attributes)
          expect(ids).to be_a Array
          expect(ids.count).to eq 3
        end

        it 'returns numeric ids when numeric ids are specified' do
          postgres.drop_table 'User'
          attributes << Attribute.new(:id, Integer)
          data.first[:id] = 1234
          ids = postgres.insert 'User', data, attributes
          expect(ids.first).to be == 1234
          postgres.drop_table 'User'
        end
      end

      it 'counts objects' do
        expect { postgres.insert 'User', data, attributes }.to change { postgres.count('User') }.by 1
      end

      it 'counts objects with a string query' do
        insert = proc { postgres.insert 'User', data, attributes }
        expect(&insert).to     change { postgres.count('User', "name = 'Jamie'") }.by 1
        expect(&insert).not_to change { postgres.count('User', "name = 'Jessica'") }
      end

      it 'returns a count of 0 when the table does not exist' do
        postgres.drop_table 'Article'
        expect(postgres.count('Article')).to be == 0
      end

      it 'returns no rows when the table does not exist' do
        postgres.drop_table 'Article'
        expect(postgres.retrieve('Article', 'TRUE')).to be == []
      end

      it 'updates a specific record' do
        id = postgres.insert('User', data, attributes).first
        postgres.update 'User', id, name: 'foo'

        retrieved = postgres.retrieve 'User', "id = '#{id}'"
        expect(retrieved.first['name']).to be == 'foo'
      end

      it 'updates a record when a column does not currently exist' do
        id = postgres.insert('User', data, attributes).first
        postgres.update 'User', id, Postgres::SerializedData.new(['foo'], ["'bar'"])

        retrieved = postgres.retrieve('User', "id = '#{id}'")
        expect(retrieved.first['foo']).to be == 'bar'
      end

      describe 'deletion' do
        it 'deletes all records' do
          postgres.insert 'User', data, attributes
          postgres.delete_all 'User'
          expect(postgres.count('User')).to be == 0
        end

        it 'deletes a record with a specific id' do
          id = postgres.insert('User', data, attributes).first
          expect { postgres.delete id, 'User' }.to change { postgres.count 'User' }.by -1
        end

        it 'deletes records with specific ids' do
          ids = Array.new(3) { postgres.insert('User', data, attributes).first }
          expect { postgres.delete ids.take(2), 'User' }.to change { postgres.count 'User' }.by -2
        end
      end

      describe 'incrementing/decrementing' do
        let(:attributes) { AttributeSet.new }
        let(:data) { [Postgres::SerializedData.new([:n], [1])] }

        before do
          attributes << Attribute.new(:n, Fixnum)
        end

        it 'increments a value for a record' do
          id = postgres.insert('Increment', data, attributes).first
          postgres.increment 'Increment', id, :n, 10
          expect(postgres.find('Increment', id)['n']).to be == '11'
        end
      end
    end

    describe 'query generation' do
      it 'creates SQL queries with a block' do
        expect(postgres.query { |o| o.name == 'foo' }.to_db).to be ==
          "name = 'foo'"
      end

      it 'does not allow SQL injection' do
        query = postgres.query { |o| o.name == "' OR 1; --" }.to_db
        expect(query).to be == "name = ''' OR 1; --'"
      end

      it 'limits results' do
        query = postgres.query
        sql = postgres.select(from: 'Article', where: query, limit: 2)
        expect(sql).to be == %Q{SELECT * FROM "Article" WHERE TRUE LIMIT 2}
      end

      describe 'ordering results' do
        it 'orders results without a qualifier' do
          sql = postgres.select(from: 'Article', order: :title)
          expect(sql).to be == %Q{SELECT * FROM "Article" ORDER BY title}
        end

        it 'orders results with asc' do
          sql = postgres.select(from: 'Article', order: { title: :asc })
          expect(sql).to be == %Q{SELECT * FROM "Article" ORDER BY title ASC}
        end

        it 'reverse-orders results' do
          sql = postgres.select(from: 'Article', order: { title: :desc })
          expect(sql).to be == %Q{SELECT * FROM "Article" ORDER BY title DESC}
        end
      end
    end

    describe 'indexes' do
      let(:title) { Postgres::Table::Attribute.new('title', String) }

      before do
        postgres.drop_table Object
        postgres.create_table Object, [title]
      end

      after do
        postgres.drop_table Object
      end

      it 'retrieves the active indexes from the database' do
        index = postgres.index(Object, Attribute.new(:title, String), unique: true)
        postgres.activate_index! index

        active_indexes = postgres.active_indexes(Object)
        index = active_indexes.find { |i| i.attribute_names == ['title'] }
        expect(index.attribute_names).to be == ['title']
        expect(index.table).to be == 'Object'
        expect(index).to be_unique
        expect(index).to be_active
      end

      describe 'adding indexes to the database' do
        it 'adds an inactive index to the database' do
          title_attribute = Attribute.new(:title, String)
          postgres.index Object, title_attribute
          index = postgres.indexes(Object).find { |i| i.attributes.map(&:name) == [:title] }
          expect(index.attribute_names).to be == ['title']
          expect(index.table).to be == 'Object'
          expect(index).not_to be_unique
          expect(index).not_to be_active
        end

        it 'activates the specified index' do
          title_attribute = Attribute.new(:title, String)
          index = postgres.index Object, title_attribute
          postgres.activate_index! index
          expect(postgres.active_indexes(Object).map(&:attribute_names)).to include ['title']
        end
      end

      describe 'removing indexes' do
        it 'removes the specified index' do
          index = postgres.index(Object, Attribute.new(:title, String))
          postgres.activate_index! index
          postgres.remove_index index
          expect(postgres.active_indexes(Object).map(&:attribute_names)).not_to include ['title']
        end
      end
    end
  end
end
