require "core/color.rb"

module Network
  class Connection
    MAX_RECV = 1024
    
    def initialize( socket )
      raise "socket wasn't a TCPSocket" unless socket.kind_of? TCPSocket
      @socket = socket
      @clientside_disconnect = false
      @connected = true
      @raw = ""
    end

    def tick
      data = @socket.recv_nonblock MAX_RECV rescue nil
      return unless data
      if data.length < 1
        Log::info "socket #{id} received eof", "connections"
        @clientside_disconnect = true
        disconnect
      else
        @raw += data
      end
    end

    def id
      @socket.object_id
    end

    def send( msg )
      begin
        @socket.send color(msg + "{@"), 0
      rescue Exception => e
        Log::error "socket #{id} exception raised in socket.send():"
        Log::error "#{e.backtrace.join ", "}"
        Log::error e.to_s
        @clientside_disconnect = true
        disconnect
      end
    end

    def next_command
      if @raw =~ /.*--\r?\n?/m
        old_raw = @raw
        @raw = $'
        Log::debug "socket #{id} flushed command queue (old raw (#{Util.strip_newlines old_raw}), new raw (#{Util.strip_newlines @raw})", "connections"
      end
      cmd = nil
      if @raw =~ /.*?\r?\n/
        @raw = $'
        cmd = $&.chomp.lstrip.gsub /[^[:print:]]/, ""
        Log::debug "socket #{id} next command (#{cmd}), remaining raw (#{Util.strip_newlines @raw})", "connections"
      end
      cmd
    end

    def connected?
      @connected
    end

    def clientside_disconnect?
      @clientside_disconnect
    end

    def client_disconnected
      clientside_disconnect?
    end

    def disconnect
      raise "socket already disconnected" unless @connected
      @socket.close rescue nil
      @raw = ""
      @connected = false
      Log::info "socket #{id} disconnected", "connections"
    end
  end
end
