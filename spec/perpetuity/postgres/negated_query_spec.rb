require 'perpetuity/postgres/negated_query'

module Perpetuity
  class Postgres
    describe NegatedQuery do
      it 'negates equality' do
        NegatedQuery.new { |o| o.name == 'foo' }.to_db.should == "NOT (name = 'foo')"
      end

      it 'negates regex matching' do
        NegatedQuery.new { |o| o.name =~ /foo/ }.to_db.should == "NOT (name ~ 'foo')"
      end

      it 'negates case-insensitive regex matching' do
        NegatedQuery.new { |o| o.name =~ /foo/i }.to_db.should == "NOT (name ~* 'foo')"
      end

      it 'negates inequality' do
        NegatedQuery.new { |o| o.name != /foo/i }.to_db.should == "NOT (name != 'foo')"
      end

      it 'negates greater-than' do
        NegatedQuery.new { |o| o.age > 1 }.to_db.should == "NOT (age > 1)"
      end

      it 'negates greater-than-or-equal' do
        NegatedQuery.new { |o| o.age >= 1 }.to_db.should == "NOT (age >= 1)"
      end

      it 'negates less-than' do
        NegatedQuery.new { |o| o.age < 1 }.to_db.should == "NOT (age < 1)"
      end

      it 'negates less-than-or-equal' do
        NegatedQuery.new { |o| o.age <= 1 }.to_db.should == "NOT (age <= 1)"
      end
    end
  end
end
