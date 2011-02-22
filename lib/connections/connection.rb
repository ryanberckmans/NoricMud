require "core/color.rb"

module Connections
  class Connection
    MAX_RECV = 1024
    
    def initialize( socket )
      @socket = socket
      @connected = true
      @raw = ""
    end

    def tick
      data = @socket.recv_nonblock MAX_RECV rescue nil
      return unless data
      if data.length < 1
        Log::info "socket #{id} received eof", "connections"
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
        @socket.send color(msg), 0
      rescue Exception => e
        Log::error "#{e.backtrace.join ", "}"
        Log::error e.to_s
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
        cmd = $&.chomp.gsub /[^[:print:]]/, ""
        Log::debug "socket #{id} next command (#{cmd}), remaining raw (#{Util.strip_newlines @raw})", "connections"
      end
      cmd
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