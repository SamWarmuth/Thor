class Game
  attr_accessor :name,:rooms, :users, :npcs, :objects
  
  def initialize(name = "New Game")
    @name = name
    @rooms = []
    @users = []
    @npcs = []
    @objects = []
  end
  
  def dup
    new_game = Game.new(@name)
    new_game.rooms = @rooms
    new_game.users = @users
    new_game.npcs = @npcs
    new_game.objects = @objects
    new_game.users = @users.map{|u| u.dup}
    return new_game
  end
end