require 'rubygems'
require 'eventmachine'
require 'lib'
require 'living'
require 'room'
$game = Game.new("Master")
$rooms = $game.rooms
$users = $game.users
$connections = []

$main_hall = Room.new("The Main Hall", "The starting point of your adventure", {:east => Room.new("Easter"), :west => Room.new("Wester")})


module EchoServer
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
        @user.connection = self
      else
        send_data "new user #{data.strip}\n"
        @user = User.new(data.strip)
        @user.connection = self
      end
      @user.move_to($main_hall)
      $users << @user
      @user.look
      return
    end
    
    command = data.strip.split(" ").first
    content = data.strip.split(" ")[1..-1]
    case command
      when "say" then @user.say(content.join(" "))
      when "look" then @user.look
      when "go" then @user.move(content.first); @user.look
      when "tell" then @user.tell(content.first, content[1..-1].join(" "))
      when "quit" then @user.logout
      when "rename" then @user.room_name(content.join(" ")); @user.look
      when "redescribe" then @user.room_description(content.join(" ")); @user.look
      when "save" then save_game(content.join(" ")); @user.send_message("Game Saved.\n")
      else @user.send_message("huh?\n")
    end
  end
  
  def save_game(name)
    name = Time.now.strftime("%d%b%y")
    game = Game.new
    save = File.open("saves/#{game.name} #{name}.save", 'w') {|file| Marshal.dump(game, file)}
  end
end