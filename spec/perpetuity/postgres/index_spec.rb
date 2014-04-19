require 'perpetuity/postgres/index'

module Perpetuity
  class Postgres
    describe Index do
      it 'can be generated from SQL results' do
        index_hash = {
          "name"=>"Object_id_name_index",
          "attributes"=>"{id,name}",
          "unique"=>"t",
          "active"=>"t"
        }

        index = Index.from_sql(index_hash)
        index.attribute_names.should == ['id', 'name']
        index.name.should == 'Object_id_name_index'
        index.table.should == 'Object'
        index.should be_unique
        index.should be_active
      end

      it 'sets itself as active' do
        index = Index.new(attributes: double('Attributes'),
                          name: 'Table',
                          unique: false)

        index.should_not be_active
        index.activate!
        index.should be_active
      end

      describe 'equality' do
        let(:attributes) { [:id, :name] }
        let(:name) { 'Object' }
        let(:unique) { true }
        let(:index) do
          Index.new(attributes: [:id, :name],
                    name: name,
                    unique: true)
        end

        it 'is equal to an index with identical state' do
          new_index = index.dup
          new_index.should == index
        end

        it 'is not equal to an index with different attributes' do
          new_index = Index.new(attributes: [:lol],
                                name: name,
                                unique: unique)

          new_index.should_not == index
        end

        it 'is equal to an index with stringified attributes' do
          new_index = Index.new(attributes: attributes.map(&:to_s),
                                name: name,
                                unique: unique)
          new_index.should == index
        end

        it 'is not equal to an index with another name' do
          new_index = Index.new(attributes: attributes,
                                name: 'NotObject',
                                unique: unique)

          new_index.should_not == index
        end

        it 'is not equal to an index with opposite uniqueness' do
          new_index = Index.new(attributes: attributes,
                                name: name,
                                unique: !unique)
          new_index.should_not == index
        end

        it 'is not equal to things that are not indexes' do
          index.should_not == 'lol'
        end
      end
    end
  end
end
