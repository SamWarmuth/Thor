require 'main'

EventMachine::run {
  EventMachine::start_server "localhost", (ENV['PORT'] || 8081), Server
  puts "Started, listening on 8081"
}