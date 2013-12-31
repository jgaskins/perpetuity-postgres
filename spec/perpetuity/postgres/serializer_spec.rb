require 'perpetuity/postgres/serializer'
require 'perpetuity/mapper'
require 'perpetuity/mapper_registry'
require 'support/test_classes/book'
require 'support/test_classes/person'

module Perpetuity
  class Postgres
    describe Serializer do
      let(:registry) { MapperRegistry.new }
      let!(:book_mapper) do
        registry = self.registry
        Class.new(Mapper) do
          map Book, registry
          attribute :title, type: String
          attribute :authors, type: Array[Person], embedded: true
          attribute :main_character, type: Person
        end.new(registry)
      end
      let!(:person_mapper) do
        registry = self.registry
        Class.new(Mapper) do
          map Person, registry
          attribute :name, type: String
        end.new(registry)
      end
      let(:serializer) { Serializer.new(book_mapper) }

      it 'serializes simple objects' do
        serializer.serialize(Book.new('Foo')).to_s.should ==
          %q{(title,authors,main_character) VALUES ('Foo','[]',NULL)}
      end

      describe 'serializing complex objects' do
        let(:jamie) { Person.new('Jamie') }
        let(:jamie_json) { '{"name":"Jamie","__metadata__":{"class":"Person"}}' }
        let(:character) { Person.new('Character') }
        let(:character_json) { '{"__metadata__":{"class":"Person","id":1}}' }

        before { character.instance_variable_set :@id, 1 }

        context 'with nested objects' do
          let(:book) { Book.new('Foo', jamie, character) }
          it 'converts objects into JSON' do
            serializer.serialize(book).to_s.should ==
              %Q{(title,authors,main_character) VALUES ('Foo','#{jamie_json}','#{character_json}')}
          end
        end

        context 'with arrays of nested objects' do
          let(:book) { Book.new('Foo', [jamie], [character]) }

          it 'adds the JSON array' do
            serializer.serialize(book).to_s.should ==
              %Q{(title,authors,main_character) VALUES ('Foo','[#{jamie_json}]','[#{character_json}]')}
          end
        end
      end

      context 'with natively serializable values' do
        it 'serializes strings' do
          serializer.serialize_attribute('string').should == "'string'"
        end

        it 'serializes numbers' do
          serializer.serialize_attribute(1).should == '1'
          serializer.serialize_attribute(1.5).should == '1.5'
        end

        it 'serializes nil' do
          serializer.serialize_attribute(nil).should == 'NULL'
        end

        it 'serializes booleans' do
          serializer.serialize_attribute(true).should == 'TRUE'
          serializer.serialize_attribute(false).should == 'FALSE'
        end

        it 'serializes Time objects' do
          time = Time.new(2000, 1, 2, 3, 4, 5.123456, '-04:00')
          serializer.serialize_attribute(time).should == "'2000-01-02 03:04:05.123456-0400'::timestamptz"
        end

        it 'serializes an array as JSON' do
          serializer.serialize_attribute([1, 'foo']).should == %q{'[1,"foo"]'}
        end

        it 'serializes a hash as JSON' do
          serializer.serialize_attribute(a: 1, foo: ['bar']).should == %q{'{"a":1,"foo":["bar"]}'}
        end
      end

      describe 'unserialization AKA deserialization' do
        let(:author) { Person.new('Me') }
        let(:serialized_book) do
          {
            'id' => 'id-id-id',
            'title' => 'My Book',
            'authors' => [
            ].to_json,
            'main_character' => nil
          }
        end

        it 'deserializes an object that embeds another object' do
          serialized_authors = [{
            '__metadata__' => { 'class' => 'Person' },
            'name' => 'Me'
          }].to_json
          serialized_book['authors'] = serialized_authors
          book = Book.new('My Book', [author])
          serializer.unserialize(serialized_book).should == book
        end

        it 'deserializes an object which references another object' do
          serialized_book['main_character'] = {
            '__metadata__' => {
              'class' => 'Person',
              'id' => 'id-id-id'
            }
          }.to_json
          deserialized_book = Book.new('My Book', [], Reference.new(Person, 'id-id-id'))
          serializer.unserialize(serialized_book).should == deserialized_book
        end

        let(:article_class) do
          Class.new do
            attr_reader :title, :body, :views, :published_at
            def initialize attributes={}
              @title = attributes[:title]
              @body = attributes[:body]
              @views = attributes.fetch(:views) { 0 }
              @published_at = attributes.fetch(:published_at) { Time.now }
            end

            def == other
              other.is_a?(self.class) &&
              other.title == title &&
              other.body == body &&
              other.views == views &&
              other.published_at == published_at
            end
          end
        end
        let(:article_mapper) do
          article_class = self.article_class
          registry = self.registry
          Class.new(Mapper) do
            map article_class, registry
            attribute :title, type: String
            attribute :body, type: String
            attribute :views, type: Integer
            attribute :published_at, type: Time
          end.new(registry)
        end

        it 'deserializes non-string attributes to their proper types' do
          serializer = Serializer.new(article_mapper)
          serialized_article = {
            'id' => 'id-id-id',
            'title' => 'Title',
            'body' => 'Body',
            'views' => '0',
            'published_at' => '2013-01-02 03:04:05.123456-05'
          }

          article = article_class.new(
            title: 'Title',
            body: 'Body',
            views: 0,
            published_at: Time.new(2013, 1, 2, 3, 4, 5.123456, '-05:00')
          )
          serializer.unserialize(serialized_article).should == article
        end
      end

      describe 'identifying embedded/referenced objects as foreign' do
        it 'sees hashes with metadata keys as foreign objects' do
          serializer.foreign_object?({'__metadata__' => 'lol'}).should be_true
        end

        it 'sees hashes without metadata keys as simple hashes' do
          serializer.foreign_object?({ 'name' => 'foo' }).should be_false
        end
      end

      describe 'identifying possible JSON strings' do
        it 'identifies JSON objects' do
          serializer.possible_json_value?('{"name":"foo"}').should be_true
        end

        it 'identifies JSON arrays' do
          serializer.possible_json_value?('[{"name":"foo"}]').should be_true
        end

        it 'rejects things it does not detect as either of the above' do
          serializer.possible_json_value?('foo is my name').should be_false
        end
      end

      it 'serializes changes between two objects' do
        original = Book.new('Old title')
        modified = original.dup
        modified.title = 'New title'
        serializer.serialize_changes(modified, original).should ==
          SerializedData.new([:title], ["'New title'"])
      end

      it 'serializes a reference as its referenced class' do
        reference = Reference.new(Object, 123)
        serializer.serialize_reference(reference).should == JSONHash.new(
          __metadata__: {
            class: Object,
            id: 123
          }
        )
      end
    end
  end
end
