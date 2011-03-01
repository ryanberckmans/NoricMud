require 'socket'

require Util.here 'connection.rb'

class Network
  DEFAULT_PORT = 4000
  MAX_ACCEPTS_PER_TICK = 3
  
  def initialize( port=DEFAULT_PORT )
    @server = TCPServer.new port
    @connections = {}
    @new_connections_this_tick = []
    @new_connections = []
    @new_disconnections = []
    Log::info "server started on port #{port}, accepting maximum of #{MAX_ACCEPTS_PER_TICK} connections per tick", "connections"
  end

  def next_connection
    @new_connections.shift
  end

  def next_disconnection
    @new_disconnections.shift
  end

  def tick
    @new_connections_this_tick.clear
    accept_connections
    tick_connections
    @new_connections_this_tick.each do |conn_id|
      if @new_disconnections.index conn_id
        @new_disconnections.delete conn_id
      else
        @new_connections << conn_id
      end
    end
  end

  def next_command( conn_id )
    @connections[conn_id].next_command
  end

  def disconnect( conn_id )
    @connections[conn_id].disconnect
    @connections.delete conn_id
  end

  def send( conn_id, msg )
    @connections[conn_id].send msg
  end

  def shutdown
    @connections.each do |conn| conn.disconnect end
    @server.close
  end

  private
  def accept_connections
    accepts = 0
    while true
      socket = @server.accept_nonblock rescue nil
      if socket
        conn = Connection.new socket
        @connections[ conn.id ] = conn
        @new_connections_this_tick << conn.id
        Log::info "accepted connection #{conn.id}", "connections"
        accepts += 1
        redo if accepts < MAX_ACCEPTS_PER_TICK
      end
      break
    end
  end

  def tick_connections
    @connections.each_value do |conn| conn.tick end
    @connections.delete_if do |conn_id, conn|
      @new_disconnections << conn.id if conn.client_disconnected
      conn.client_disconnected
    end
  end
end
