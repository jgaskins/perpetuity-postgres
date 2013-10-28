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
          attribute :authors, type: Array, embedded: true
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

      it 'serializes complex objects' do
        jamie = Person.new('Jamie')
        jamie_json = { name: 'Jamie', __metadata__: { class: Person } }.to_json
        character = Person.new('Character')
        character.instance_variable_set :@id, 1
        character_json = { __metadata__: { class: Person, id: 1 } }.to_json
        book = Book.new('Foo', [jamie], character)

        serializer.serialize(book).to_s.should ==
          %Q{(title,authors,main_character) VALUES ('Foo','[#{jamie_json}]','#{character_json}')}
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
    end
  end
end
