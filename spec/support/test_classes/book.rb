class Book
  attr_accessor :title, :authors, :main_character

  def initialize title, authors=[], main_character=nil
    @title = title
    @authors = authors
    @main_character = main_character
  end

  def == other
    other.is_a?(Book) &&
    other.title == title &&
    other.authors == authors &&
    other.main_character == main_character
  end
end
