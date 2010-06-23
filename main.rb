require 'rubygems'
require 'eventmachine'
require 'living'
require 'room'

$main_hall = Room.new
$main_hall.name = "Main Hall"
$main_hall.exits = [Room.new, Room.new]
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
    # The first message from the user is its name
    if @user.nil?
      @user = User.new
      @user.username = data.strip
      @user.location = $main_hall
      $users << @user
      send_data "You are standing in the #{@user.location}\n"
      return
    end
    
    
    
    $connections.each do |client|
      # Send the message from the client to all other clients
      client.send_data "#{@user.username} says: #{data.strip} from #{@user.location}\n"
    end

  end
end

EventMachine::run {
  EventMachine::start_server "127.0.0.1", 8081, EchoServer
  puts 'running echo server on 8081'
}