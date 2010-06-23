class Living
  attr_accessor :name, :class, :location
  
  def move_to(room)
    @location = room
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
  attr_accessor :username, :pass_hash, :connection
  
  def initialize(username = 10.times.map{|l|('a'..'z').to_a[rand(25)]}.join)
    @username = username
  end
  
  def send_message(message)
    return false if connection.nil?
    @connection.send_data(message)
    return true
  end
  
  def say(message)
    $users.each {|user| user.send_message("#{@username} says: #{message} from #{@location}\n")}
  end
  
  def tell(user, message)
    found = $users.find{|u| u.username.downcase == user.downcase}
    if found.nil?
      send_message("#{user} not found")
    else
      found.send_message("#{@username} says: #{message}\n")
      send_message("You said '#{message}' to #{user}\n")
    end
  end
  
  def look
    send_message("You're standing in #{@location.name}\n You see:\n  #{@location.contents.join("\n  ")}\n There are exits #{@location.exits.keys.join(", ")}\n")
  end
  
  def logout
    unless @connection.nil?
      send_message("Seeya!")
      @connection.close_connection
      @user.connection = nil
    end
  end
  
  def to_s
    @username
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
end


