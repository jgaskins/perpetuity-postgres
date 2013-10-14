class Book
  attr_accessor :title

  def initialize title, authors=[], main_character=nil
    @title = title
    @authors = authors
    @main_character = main_character
  end
end
