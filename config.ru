require 'main'

EventMachine::run {
  EventMachine::start_server "localhost", 8081, Server
  puts 'Running Server on 8081'
}