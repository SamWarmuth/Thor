class Game
  attr_accessor :name,:rooms, :users, :npcs, :objects
  
  def initialize(name = "New Game")
    @name = name
    @rooms = []
    @users = []
    @npcs = []
    @objects = []
  end
  
end