require 'perpetuity/postgres'
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
        end.new(registry)
      end
      let!(:person_mapper) do
        registry = self.registry
        Class.new(Mapper) do
          map Person, registry
          attribute :name, type: String
        end.new(registry)
      end
      let(:data_source) { Postgres.new(db: 'perpetuity_gem_test') }
      let(:serializer) { Serializer.new(book_mapper) }

      it 'serializes simple objects' do
        serializer.serialize(Book.new('Foo')).should == %q{('Foo','[]')}
      end

      it 'serializes complex objects' do
        jamie = Person.new('Jamie')
        jamie_json = { name: 'Jamie', __metadata__: { class: Person } }.to_json
        book = Book.new('Foo', [jamie])

        person_mapper.class.stub(data_source: data_source)

        serializer.serialize(book).should == %Q{('Foo','[#{jamie_json}]')}
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

        it 'serializes an array as JSON' do
          serializer.serialize_attribute([1, 'foo']).should == %q{'[1,"foo"]'}
        end
      end
    end
  end
end
