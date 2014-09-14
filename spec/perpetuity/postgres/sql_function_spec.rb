require 'perpetuity/postgres/sql_function'

module Perpetuity
  class Postgres
    describe SQLFunction do
      it 'converts to a SQL function call' do
        function = SQLFunction.new('json_array_length', :comments)
        expect(function.to_s).to be == 'json_array_length(comments)'
      end

      it 'takes multiple arguments' do
        function = SQLFunction.new('compare', :a, :b)
        expect(function.to_s).to be == 'compare(a,b)'
      end
    end
  end
end
