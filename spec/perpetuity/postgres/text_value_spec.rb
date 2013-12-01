require 'perpetuity/postgres/text_value'

module Perpetuity
  class Postgres
    describe TextValue do
      it 'serializes into a Postgres-compatible string' do
        TextValue.new('Jamie').to_s.should == "'Jamie'"
      end

      it 'escapes single quotes' do
        TextValue.new("Jamie's house").to_s.should == "'Jamie''s house'"
      end
    end
  end
end
