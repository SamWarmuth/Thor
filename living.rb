class Living
  attr_accessor :name, :class, :location
  
  def go_to(room)
    @location = room
  end
  
  def move(direction)
    return "You can't go that way.\n" if @location.exits[direction.to_sym].nil?
    
    @location = @location.exits[direction.to_sym] 
    return "You move #{direction}.\n"
  end
  
  def say
    "#{@name} says: #{message} from #{@location}\n"
  end
  
  def to_s
    @name
  end
end

class User < Living
  attr_accessor :username, :pass_hash
  
  def initialize(username = 10.times.map{|l|('a'..'z').to_a[rand(25)]}.join)
    @username = username
  end
  
  def say(message)
    "#{@username} says: #{message} from #{@location}\n"
  end
  
  def look
    return "You're standing in #{@location.name}\n You see:\n  #{@location.contents.join("\n  ")}\n There are exits #{@location.exits.keys.join(", ")}\n"
  end
  
  def to_s
    @username
  end
  
end


class SuperUser < User
  
  def go(direction)
    if @location.exits[direction.to_sym].nil?
      @location.exits[direction.to_sym] = Room.new
    end
    super
  end
end


