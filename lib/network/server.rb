require 'socket'

require Util.here 'connection.rb'

module Network
  class Server
    PORT = 4000
    MAX_ACCEPTS_PER_TICK = 3
    
    def initialize
      @server = TCPServer.new PORT
      @connections = {}
      @new_connections = []
      @new_disconnections = []
      Log::info "tcp server started on port #{PORT}, accepting maximum of #{MAX_ACCEPTS_PER_TICK} connections per tick", "connections"
    end

    def new_connections
      @new_connections
    end

    def new_disconnections
      @new_disconnections
    end

    def tick
      @new_connections.clear
      @new_disconnections.clear
      accept_connections
      tick_connections
    end

    def next_command( conn_id )
      @connections[conn_id].next_command
    end

    def disconnect( conn_id )
      @connections[conn_id].disconnect
    end

    def send( conn_id, msg )
      @connections[conn_id].send msg
    end

    private

    def accept_connections
      accepts = 0
      while true
        socket = @server.accept_nonblock rescue nil
        if socket
          conn = Connection.new socket
          @connections[ conn.id ] = conn
          @new_connections << conn.id
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
        connected = conn.connected?
        if not connected
          @new_disconnections << conn.id if conn.clientside_disconnect?
        end
        not connected
      end
    end
  end # class Server
end # module Network
