require 'perpetuity/postgres/negated_query'

module Perpetuity
  class Postgres
    describe NegatedQuery do
      it 'negates equality' do
        expect(NegatedQuery.new { |o| o.name == 'foo' }.to_db).to be == "NOT (name = 'foo')"
      end

      it 'negates regex matching' do
        expect(NegatedQuery.new { |o| o.name =~ /foo/ }.to_db).to be == "NOT (name ~ 'foo')"
      end

      it 'negates case-insensitive regex matching' do
        expect(NegatedQuery.new { |o| o.name =~ /foo/i }.to_db).to be == "NOT (name ~* 'foo')"
      end

      it 'negates inequality' do
        expect(NegatedQuery.new { |o| o.name != /foo/i }.to_db).to be == "NOT (name != 'foo')"
      end

      it 'negates greater-than' do
        expect(NegatedQuery.new { |o| o.age > 1 }.to_db).to be == "NOT (age > 1)"
      end

      it 'negates greater-than-or-equal' do
        expect(NegatedQuery.new { |o| o.age >= 1 }.to_db).to be == "NOT (age >= 1)"
      end

      it 'negates less-than' do
        expect(NegatedQuery.new { |o| o.age < 1 }.to_db).to be == "NOT (age < 1)"
      end

      it 'negates less-than-or-equal' do
        expect(NegatedQuery.new { |o| o.age <= 1 }.to_db).to be == "NOT (age <= 1)"
      end
    end
  end
end
