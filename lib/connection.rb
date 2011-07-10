require "color.rb"

class Connection
  RECV_MAX = 512
  RAW_MAX = 1024
  
  def initialize( socket )
    raise "socket wasn't a TCPSocket" unless socket.kind_of? TCPSocket
    @socket = socket
    @client_disconnected = false
    @connected = true
    @raw = ""
  end

  def tick
    receive_data
  end

  def id
    @socket.object_id
  end

  def send( msg )
    return unless @connected
    begin
      @socket.send color(msg), 0
    rescue Exception => e
      Log::error "connection #{id} exception raised in socket.send():"
      Log::error "#{e.backtrace.join ", "}"
      Log::error e.to_s
      @client_disconnected = true
      disconnect
    end
  end

  def next_command
    if @raw =~ /.*--\r?\n?/m
      old_raw = @raw
      @raw = $'
      Log::debug "connection #{id} flushed command queue (old raw (#{Util.strip_newlines old_raw}), new raw (#{Util.strip_newlines @raw})", "connections"
    end
    cmd = nil
    if @raw =~ /.*?\r?\n/
      @raw = $'
      cmd = $&.chomp.lstrip.gsub /[^[:print:]]/, ""
      Log::debug "connection #{id} next command (#{cmd}), remaining raw (#{Util.strip_newlines @raw})", "connections"
    end
    cmd
  end

  def client_disconnected
    @client_disconnected
  end

  def disconnect
    Log::warn "disconnect: connection #{id} was already disconnected", "connections" unless @connected
    @socket.close rescue nil
    @raw = ""
    @connected = false
    Log::info "connection #{id} disconnected", "connections"
  end
  
  private
  def receive_data
    data = @socket.recv_nonblock RECV_MAX rescue nil
    return unless data
    if data.length < 1
      Log::info "connection #{id} received eof", "connections"
      @client_disconnected = true
      disconnect
    else
      Log::debug "connection #{id} recieved new data (#{Util.strip_newlines data}), already has raw (#{Util.strip_newlines @raw})", "connections"
      data.gsub! "_hack_newline", ""
      @raw += data unless @raw.length + data.length > RAW_MAX
    end
  end
end

