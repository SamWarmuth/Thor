require 'rubygems'
require 'eventmachine'
require 'lib'
require 'living'
require 'room'
$game = Game.new("Master")
$game.home = Room.new($game, "The Main Hall", "The starting point of your adventure", {:east => Room.new($game, "Easter"), :west => Room.new($game, "Wester")})

$connections = []


module Server
  def post_init
    #timer = EventMachine::PeriodicTimer.new(2) {send_data "10 second update."}
    $connections << self
    send_data "Please enter your username: "
  end

  def receive_data(data)
    # The first message from the user is their username
    if @user.nil?
      if data.strip[0] == "$"
        send_data "new superuser #{data.strip[1..-1]}\n"
        @user = SuperUser.new(data.strip[1..-1])
      else
        send_data "new user #{data.strip}\n"
        @user = User.new(data.strip)
      end
      
      @user.connection = self
      @user.game = $game
      @user.move_to($game.home)
      $game.users << @user
      @user.look
      return
    end
    
    command = data.strip.split(" ").first
    content = data.strip.split(" ")[1..-1]
    case command
      when "say" then @user.say(content.join(" "))
      when "yell" then @user.yell(content.join(" "))
      when "tell" then @user.tell(content.first, content[1..-1].join(" "))  
      when "look" then @user.look
      when "go" then @user.move(content.first); @user.look
      when "quit" then @user.logout
      when "exit" then @user.logout 
      when "rename" then @user.room_name(content.join(" ")); @user.look
      when "redescribe" then @user.room_description(content.join(" ")); @user.look
      when "save" then save_game(content.join(" "))
      when "load" then load_game(content.join(" "))
      else @user.send_message("huh?\n")
    end
  end
  
  def save_game(name = nil)
    name ||= Time.now.strftime("%d%b%y")
    File.open("saves/#{@user.game.name} #{name}.save", 'w') {|file| Marshal.dump(@user.game.dup, file)}
    @user.send_message("Game Saved.\n")
  end
  
  def load_game(name = nil)
    name ||= Time.now.strftime("%d%b%y")
    File.open("saves/#{@user.game.name} #{name}.save", 'r') {|file| @user.game.dup = Marshal.load(file.read)}
    $connections = []
    @user.logout
    
  end
end


