class Living
  attr_accessor :name, :class, :location
  
  def move_to(room)
    $game.users.find_all{|u| u != self && u.location == @location}.each {|u| u.send_message("#{@name} left the room.\n")}
    @location = room
    $game.users.find_all{|u| u != self && u.location == @location}.each {|u| u.send_message("#{@name} entered the room.\n")}
  end
  
  def move(direction)
    if @location.exits[direction.to_sym].nil?
      send_message "You can't go that way.\n" 
      return false
    else
      move_to(@location.exits[direction.to_sym])
      send_message "You go #{direction}.\n"
    end
  end
  
  def say(message)
    $game.users.find_all{|u| u.location == @location}.each{|user| user.send_message("#{@name} says: #{message}\n")}
  end
  
  def yell(message)
    $game.users.each {|user| user.send_message("#{@name} yells: #{message} from #{@location}\n")}
  end
  
  def go_home; move_to($game.home); end
  def to_s; @name; end
end

class User < Living
  attr_accessor :pass_hash, :connection
  
  def initialize(name = 10.times.map{|l|('a'..'z').to_a[rand(25)]}.join)
    @name = name
  end
  
  def send_message(message)
    return false if connection.nil?
    @connection.send_data(message)
    return true
  end
  
  
  def tell(user, message)
    found = $game.users.find{|u| u.name.downcase == user.downcase}
    if found.nil?
      send_message("#{user} not found\n")
    else
      found.send_message("#{@name} says: #{message}\n")
      send_message("You say '#{message}' to #{user}\n")
    end
  end
  
  def look
    send_message("You're standing in #{@location.name}\n You see:\n  #{@location.contents.join("\n  ")}\n There are exits #{@location.exits.keys.join(", ")}\n")
  end
  
  def logout
    unless @connection.nil?
      @connection.close_connection
      @connection = nil
      $game.users.each {|user| user.send_message("#{@name} Logged Out.\n")}
    end
  end
  
  def room_name; return false; end
  def room_description; return false; end
  
  def dup
    new_user = User.new(@name)
    new_user.name = @name
    new_user.pass_hash = @pass_hash
    new_user.class = @class
    new_user.location = @location
    return new_user
  end
end

class SuperUser < User
  def move(direction)
    if @location.exits[direction.to_sym].nil?
      send_message("Created new room.\n")
      @location.set_loop_exits({direction.to_sym => Room.new})
    end
    super
  end
  
  def room_name(new_name)
    @location.name = new_name
    send_message("Renamed current room to '#{new_name}'.\n")
  end
  
  def room_description(new_description)
    @location.description = new_description
    send_message("Change description of current room to '#{new_description}'.\n")
  end
  
end


