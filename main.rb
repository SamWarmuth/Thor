require 'rubygems'
require 'eventmachine'
require 'living'
require 'room'

$main_hall = Room.new("The Main Hall", "The starting point of your adventure", {:east => Room.new("Easter"), :west => Room.new("Wester")})
$users = []
$connections = []


module EchoServer
  def post_init
    #timer = EventMachine::PeriodicTimer.new(2) do
    #   send_data "2 seconds!"
    #end
    $connections << self
    send_data "Please enter your username: "
  end

  def receive_data data
    # The first message from the user is their username
    if @user.nil?
      if data.strip[0] = "$"
        @user = SuperUser.new(data.strip[1..-1])
      else
        @user = User.new(data.strip)
      end
      @user.location = $main_hall
      $users << @user
      send_data @user.look
      return
    end
    
    command = data.strip.split(" ").first
    modifiers = data.strip.split(" ")[1..-1]
    case data.strip.split(" ").first
      when "say" then $connections.each {|client| client.send_data @user.say(modifiers.join(" "))}
      when "look" then send_data @user.look
      when "go" then 
        send_data @user.move(modifiers.first)
        send_data @user.look
      when "debug"
        
      else send_data "huh?\n"
    end
  end
end

EventMachine::run {
  EventMachine::start_server "127.0.0.1", 8081, EchoServer
  puts 'running echo server on 8081'
}