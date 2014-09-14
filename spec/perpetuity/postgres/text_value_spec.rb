require 'perpetuity/postgres/text_value'

module Perpetuity
  class Postgres
    describe TextValue do
      it 'serializes into a Postgres-compatible string' do
        expect(TextValue.new('Jamie').to_s).to be == "'Jamie'"
      end

      it 'escapes single quotes' do
        expect(TextValue.new("Jamie's house").to_s).to be == "'Jamie''s house'"
      end
    end
  end
end
