class Room
  @@opposites = {:east => :west, :north => :south, :up => :down, :in => :out}
  @@opposites.merge!(@@opposites.invert)
  attr_accessor :name, :description, :exits
  
  def initialize(game, name = "An Unnamed Room", description = "A room.", exits = {})
    @game = game
    @name = name
    @description = description
    @exits = {}
    set_loop_exits(exits)
    @game.rooms << self
  end
  
  def set_loop_exits(exits)
    exits.each_pair do |direction, room|
      @exits[direction] = room
      unless @@opposites[direction].nil?
        room.exits[@@opposites[direction]] = self unless room.exits[@@opposites[direction]]
      end
    end
  end
  
  def contents
    @game.users.find_all{|u| u.location == self}
  end
  def to_s
    @name
  end
end