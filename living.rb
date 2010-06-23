class Living
  attr_accessor :name, :class, :location
  
  def go_to(room)
    @location = room
  end
end

class User < Living
  attr_accessor :username, :pass_hash
  
end