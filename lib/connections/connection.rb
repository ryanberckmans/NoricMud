
module Connections
  class Connection
    MAX_RECV = 1024
    
    def initialize( socket )
      @socket = socket
      @connected = true
      @data = nil
    end

    def tick
      data = @socket.recv_nonblock MAX_RECV rescue nil
      return unless data
      if data.length < 1
        Log::info "socket #{id} received eof", "connections"
        disconnect
      else
        @data = data
      end
    end

    def id
      @socket.object_id
    end

    def send( msg )
      begin
        @socket.send msg, 0
      rescue Exception => e
        Log::error "#{e.backtrace.join ", "}"
        Log::error e.to_s
        disconnect
      end
    end

    def next_command
      d = @data
      @data = nil
      d
    end

    def connected?
      @connected
    end

    def disconnect
      @socket.close rescue nil
      @connected = false
      Log::info "socket #{id} disconnected", "connections"
    end
  end
end
