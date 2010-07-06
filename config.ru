require 'main'


EventMachine::run {
  EventMachine::start_server "0.0.0.0", (ENV['PORT'] || 8081), Server
  puts "Started, listening on 8081"
}
