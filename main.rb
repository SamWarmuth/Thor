require 'rubygems'
require 'eventmachine'
require 'lib'
require 'living'
require 'room'
$game = Game.new("Master")
$game.home = Room.new("The Main Hall", "The starting point of your adventure", {:east => Room.new("Easter"), :west => Room.new("Wester")})

$connections = []


module Server
  def post_init
    timer = EventMachine::PeriodicTimer.new(120) {send_data "\033[1mIt is pitch black. You are likely to be eaten by a Grue.\033[0m\n"}
    $connections << self
    send_data "\n\n\nWelcome.\n\nIf you're new here, type 'create <name> <password>' to create an account.\nTo log in, type 'login <name> <password>' \n"
  end

  def receive_data(data)
    command = data.strip.split(" ").first.to_s.downcase
    content = data.strip.split(" ")[1..-1]
    
    # The first message from the user is their username
    if @user.nil?
      case command
      when "create" then 
        if content[0][0] == "$"
          send_data "New Superuser #{content[0][1..-1]}\n"
          @user = SuperUser.new(content[0][1..-1])
        else
          send_data "New User #{content[0]}\n"
          @user = User.new(content[0])
        end
        
        @user.connection = self
        @user.go_home
        $game.users << @user
      when "login" then
        user = $game.users.find{|u| u.name == content.join(" ")}
        return send_data "user not found" if user.nil?
        
      when "help" then
        send_data "If you're new here, type 'Create <name> <password> to create an account.\nTo log in, type login <name> <password> \n"
      else
        send_data "huh?"
      end
      
      @user.look
      return
    end
    
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
    File.open("saves/#{$game.name} #{name}.save", 'w') {|file| Marshal.dump($game.dup, file)}
    @user.send_message("Game Saved.\n")
  end
  
  def load_game(name = nil)
    name ||= Time.now.strftime("%d%b%y")
    File.open("saves/#{$game.name} #{name}.save", 'r') {|file| $game = Marshal.load(file.read)}
    $connections = []
    @user.logout
    
  end
end


