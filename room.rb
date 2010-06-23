class Room
  attr_accessor :name, :description, :exits
  def contents
    $users.find_all{|u| u.location == self}
  end
  def to_s
    @name
  end
end