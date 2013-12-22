require 'perpetuity/postgres/sql_function'

module Perpetuity
  class Postgres
    describe SQLFunction do
      it 'converts to a SQL function call' do
        function = SQLFunction.new('json_array_length', :comments)
        function.to_s.should == 'json_array_length(comments)'
      end

      it 'takes multiple arguments' do
        function = SQLFunction.new('compare', :a, :b)
        function.to_s.should == 'compare(a,b)'
      end
    end
  end
end
