require Util::here 'server.rb'

module Network
  @server = Server.new
  
  def self.tick
    Log::debug "start tick", "connections"
    @server.tick
    Log::debug "end tick", "connections"
  end

  def self.new_connections
    @server.new_connections
  end

  def self.new_disconnections
    @server.new_disconnections
  end

  def self.next_command( connection )
    @server.next_command connection
  end

  def self.disconnect( connection )
    @server.disconnect connection
  end

  def self.send( connection, msg )
    @server.send connection, msg
  end

  Log::info "initialized", "connections"
end


