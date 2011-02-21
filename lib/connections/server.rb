require 'socket'

module Connections
  class Server
    PORT = 4000
    MAX_ACCEPTS_PER_TICK = 3
    
    def initialize
      @server = TCPServer.new PORT
      Log::info "tcp server started on port #{PORT}", "connections"
      Log::info "accepting maximum of #{MAX_ACCEPTS_PER_TICK} connections per tick", "connections"
    end

    def tick
      accepts = 0
      while true
        socket = @server.accept_nonblock rescue nil
        if socket
          # new connection
          socket.puts Time.now
          socket.puts "bye"
          socket.close
          accepts += 1
          redo if accepts < MAX_ACCEPTS_PER_TICK
        end
        break
      end
    end # tick
  end
end
