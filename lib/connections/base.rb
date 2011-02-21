require Util::here 'server.rb'

module Connections
  @server = Connections::Server.new
  
  def self.tick
    @server.tick
  end

  def self.new_connections
    @server.new_connections
  end

  def self.new_disconnections
    @server.new_disconnections
  end

  def self.next_command( conn_id )
    @server.next_command conn_id
  end

  def self.disconnect( conn_id )
    @server.disconnect conn_id
  end

  def self.send( conn_id, msg )
    @server.send conn_id, msg
  end

  Log::info "initialized", "connections"
end


