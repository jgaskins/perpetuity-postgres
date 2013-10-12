class Book
  attr_accessor :title

  def initialize title, authors=[]
    @title = title
    @authors = authors
  end
end
