require 'rubygems'
require 'eventmachine'
require 'digest/sha2'

require 'lib'
require 'living'
require 'room'

$game = Game.new("Master")
$game.home = Room.new("The Main Hall", "The starting point of your adventure", {:east => Room.new("Easter"), :west => Room.new("Wester")})

$connections = []


module Server
  def user; @user; end
  def user= (user); @user = user; end
  def post_init
    
    
    timer = EventMachine::PeriodicTimer.new(120) {send_data "\033[1mIt is pitch black. You are likely to be eaten by a Grue.\033[0m\n"}
    $connections << self
    send_data "\ncurrent users: #{$connections.find_all{|c| c.user != nil}.map{|c| c.user.name}.join(", ")}"    
    send_data "\nAll users: #{$game.users.map{|u| u.to_s}.join(", ")}"
    
    send_data "\n\nWelcome.\n\nIf you're new here, type 'create <name> <password>' to create an account.\nTo log in, type 'login <name> <password>'\n\n"

  end

  def receive_data(data)
    command = data.strip.split(" ").first.to_s.downcase
    content = data.strip.split(" ")[1..-1]
        
    # The first message from the user is their username
    if @user.nil?
      case command
      when "create" then 
        
        if content[0][0] == "$"
          return send_data "User already exists.\n" if $game.users.find{|u| u.name == content[0..-2].join(" ").to_s[1..-1]}
          
          @user = SuperUser.new(content[0..-2].join(" ").to_s[1..-1])
          $game.broadcast("New Superuser #{@user.name}\n")
        else
          return send_data "User already exists.\n" if $game.users.find{|u| u.name == content[0..-2].join(" ")}
          
          @user = User.new(content[0..-2].join(" "))
          $game.broadcast("New User #{@user.name}\n")
        end
        @user.set_password(content.last)
        @user.connection = self
        $game.users << @user
        @user.go_home
        @user.look
      when "login" then
        user = $game.users.find{|u| u.name == content[0..-2].join(" ")}
        return send_data "user not found\n" if user.nil?
        
        if User.hash_password(user, content.last) == user.pass_hash
          $game.broadcast("#{user} logged in.")
          @user = user
          @user.connection = self
          send_data "Welcome back, #{@user.name}\n"
          @user.look
        else
          send_data "Password Incorrect. Please try again.\n"
        end
      when "help" then
        send_data "If you're new here, type 'Create <name> <password> to create an account.\nTo log in, type login <name> <password> \n"
      when "exit" then close_connection
      when "quit" then close_connection
      else
        send_data "huh?\n"
      end
      
      return
    end
    
    case command
    when "rename" then @user.room_name(content.join(" ")); @user.look
    when "redescribe" then @user.room_description(content.join(" ")); @user.look
    when "save" then save_game(content.join(" "))
    when "load" then load_game(content.join(" "))
    else
      begin
        (content.nil?||content.empty?) ? @user.send(command.to_s) : @user.send(command.to_s, content)
      rescue
        @user.send("huh?\n")
      end
    end
  end
  
  def save_game(name = nil)
    name ||= Time.now.strftime("%d%b%y")
    t = Time.now
    File.open("saves/#{$game.name} #{name}.save", 'w') {|file| Marshal.dump($game.dup, file)}
    $game.broadcast("Save took #{Time.now - t} seconds\n")
    @user.send_message("Game Saved.\n")
  end
  
  def load_game(name = nil)
    $game.users.each {|user| user.send_message("Trying to load a saved game. Hold on to your hats...\n")}
    
    name ||= Time.now.strftime("%d%b%y")
    t = Time.now
    File.open("saves/#{$game.name} #{name}.save", 'r') {|file| $game = Marshal.load(file.read)}
    new_connections = []
    $connections.each do |conn|
      old_user = conn.user
      conn.user = nil
      user = $game.users.find{|u| u.name == old_user.name}
      if user.nil?
        send_data "user not found"
        next
      end  
      if user.pass_hash == old_user.pass_hash
        conn.user = user
        conn.user.connection = self
        
        conn.send_data "Found you, #{user.name}\n"
      else
        conn.send_data "Hmm. Your password isn't the same as in the save.\nPerhaps you changed it?\nPlease Log in again.\n so type quit.\n"
      end
    end
    $game.broadcast("Load took #{Time.now - t} seconds\n")
  end
end


