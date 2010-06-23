require 'main'

EventMachine::run {
  EventMachine::start_server "127.0.0.1", 8081, Server
  puts 'Running Server on 8081'
}