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
        subject { postgres }

        its(:host)      { should == host }
        its(:port)      { should == port }
        its(:db)        { should == db }
        its(:pool_size) { should == pool_size }
        its(:username)  { should == username }
        its(:password)  { should == password }
      end

      context 'default values' do
        let(:postgres) { Postgres.new(db: 'my_db') }
        subject { postgres }

        its(:host)      { should == 'localhost' }
        its(:port)      { should == 5432 }
        its(:pool_size) { should == 5 }
        its(:username)  { should == ENV['USER'] }
        its(:password)  { should be_nil }
      end
    end

    it 'creates and drops tables' do
      postgres.create_table 'Article', [
        Postgres::Table::Attribute.new('title', String, max_length: 40),
        Postgres::Table::Attribute.new('body', String),
        Postgres::Table::Attribute.new('author', Object)
      ]
      postgres.should have_table('Article')

      postgres.drop_table 'Article'
      postgres.should_not have_table 'Article'
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

      postgres.find('Article', id)['timestamp'].should =~ /2013/

      postgres.drop_table 'Article' # Cleanup
    end

    it 'converts values into something that works with the DB' do
      postgres.postgresify("string").should == "'string'"
      postgres.postgresify(1).should == '1'
      postgres.postgresify(true).should == 'TRUE'
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

        id.should =~ /[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}/
        result['name'].should == 'Jamie'
      end

      describe 'returning ids' do
        it 'returns the ids of all items saved' do
          data << Postgres::SerializedData.new([:name], ["'Jessica'"]) <<
          Postgres::SerializedData.new([:name], ["'Kevin'"])
          ids = postgres.insert('User', data, attributes)
          ids.should be_a Array
          ids.should have(3).items
        end

        it 'returns numeric ids when numeric ids are specified' do
          postgres.drop_table 'User'
          attributes << Attribute.new(:id, Integer)
          data.first[:id] = 1234
          ids = postgres.insert 'User', data, attributes
          ids.first.should == 1234
          postgres.drop_table 'User'
        end
      end

      it 'counts objects' do
        expect { postgres.insert 'User', data, attributes }.to change { postgres.count('User') }.by 1
      end

      it 'counts objects with a string query' do
        insert = proc { postgres.insert 'User', data, attributes }
        expect(&insert).to     change { postgres.count('User', "name = 'Jamie'") }.by 1
        expect(&insert).not_to change { postgres.count('User', "name = 'Jessica'") }.by 1
      end

      it 'returns a count of 0 when the table does not exist' do
        postgres.drop_table 'Article'
        postgres.count('Article').should == 0
      end

      it 'returns no rows when the table does not exist' do
        postgres.drop_table 'Article'
        postgres.retrieve('Article', 'TRUE').should == []
      end

      it 'updates a specific record' do
        id = postgres.insert('User', data, attributes).first
        postgres.update 'User', id, name: 'foo'

        retrieved = postgres.retrieve 'User', "id = '#{id}'"
        retrieved.first['name'].should == 'foo'
      end

      describe 'deletion' do
        it 'deletes all records' do
          postgres.insert 'User', data, attributes
          postgres.delete_all 'User'
          postgres.count('User').should == 0
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
          postgres.find('Increment', id)['n'].should == '11'
        end
      end
    end

    describe 'query generation' do
      it 'creates SQL queries with a block' do
        postgres.query { |o| o.name == 'foo' }.to_db.should ==
          "name = 'foo'"
      end

      it 'does not allow SQL injection' do
        query = postgres.query { |o| o.name == "' OR 1; --" }.to_db
        query.should == "name = ''' OR 1; --'"
      end

      it 'limits results' do
        query = postgres.query
        sql = postgres.select(from: 'Article', where: query, limit: 2)
        sql.should == %Q{SELECT * FROM "Article" WHERE TRUE LIMIT 2}
      end

      describe 'ordering results' do
        it 'orders results without a qualifier' do
          sql = postgres.select(from: 'Article', order: :title)
          sql.should == %Q{SELECT * FROM "Article" ORDER BY title}
        end

        it 'orders results with asc' do
          sql = postgres.select(from: 'Article', order: { title: :asc })
          sql.should == %Q{SELECT * FROM "Article" ORDER BY title ASC}
        end

        it 'reverse-orders results' do
          sql = postgres.select(from: 'Article', order: { title: :desc })
          sql.should == %Q{SELECT * FROM "Article" ORDER BY title DESC}
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
        index.attribute_names.should == ['title']
        index.table.should == 'Object'
        index.should be_unique
        index.should be_active
      end

      describe 'adding indexes to the database' do
        it 'adds an inactive index to the database' do
          title_attribute = Attribute.new(:title, String)
          postgres.index Object, title_attribute
          index = postgres.indexes(Object).find { |i| i.attributes.map(&:name) == [:title] }
          index.attribute_names.should == ['title']
          index.table.should == 'Object'
          index.should_not be_unique
          index.should_not be_active
        end

        it 'activates the specified index' do
          title_attribute = Attribute.new(:title, String)
          index = postgres.index Object, title_attribute
          postgres.activate_index! index
          postgres.active_indexes(Object).map(&:attribute_names).should include ['title']
        end
      end

      describe 'removing indexes' do
        it 'removes the specified index' do
          index = postgres.index(Object, Attribute.new(:title, String))
          postgres.activate_index! index
          postgres.remove_index index
          postgres.active_indexes(Object).map(&:attribute_names).should_not include ['title']
        end
      end
    end
  end
end
