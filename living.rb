class Living
  attr_accessor :name, :class, :location
  
  def move_to(room)
    $users.find_all{|u| u != self && u.location == @location}.each {|u| u.send_message("#{@name} left the room.\n")}
    @location = room
    $users.find_all{|u| u != self && u.location == @location}.each {|u| u.send_message("#{@name} entered the room.\n")}
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
  
  def say
    $users.each {|user| user.send_message("#{@name} says: #{message} from #{@location}\n")}
  end
  
  def to_s
    @name
  end
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
  
  def say(message)
    $users.each {|user| user.send_message("#{@name} says: #{message} from #{@location}\n")}
  end
  
  def tell(user, message)
    found = $users.find{|u| u.name.downcase == user.downcase}
    if found.nil?
      send_message("#{user} not found")
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
      $users.each {|user| user.send_message("#{@name} Logged Out.\n")}
    end
  end
  
  def room_name; return false; end
  def room_description; return false; end
  
  def to_s
    @name
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


