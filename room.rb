class Room
  attr_accessor :name, :description, :exits
  
  def initialize(name = "An Unnamed Room", description = "A room.", exits = {})
    @name = name
    @description = description
    @exits = exits
  end
  
  def contents
    $users.find_all{|u| u.location == self}
  end
  def to_s
    @name
  end
end