require 'noric_mud/easy_class_log'
require 'noric_mud/util'
require 'noric_mud/color'

module NoricMud
  module Network
    class Connection
      include EasyClassLog
      
      RECV_MAX = 512
      RAW_MAX = 1024
      
      def initialize socket
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

      def send msg
        return unless @connected
        begin
          @socket.send Color::color(msg), 0
        rescue Exception => e
          error { "connection #{id} exception raised in socket.send():" }
          error { "#{e.backtrace.join ", "}" }
          error { e.to_s }
          @client_disconnected = true
          disconnect
        end
      end

      def next_command
        if @raw =~ /.*--\r?\n?/m
          old_raw = @raw
          @raw = $'
          debug { "connection #{id} flushed command queue (old raw (#{Util.strip_newlines old_raw}), new raw (#{Util.strip_newlines @raw})" }
        end
        cmd = nil
        if @raw =~ /.*?\r?\n/
          @raw = $'
          cmd = $&.chomp.lstrip.gsub /[^[:print:]]/, ""
          debug { "connection #{id} next command (#{cmd}), remaining raw (#{Util.strip_newlines @raw})" }
        end
        cmd
      end

      def client_disconnected
        @client_disconnected
      end

      def disconnect
        warn { "disconnect: connection #{id} was already disconnected" } unless @connected
        @socket.close rescue nil
        @raw = ""
        @connected = false
        info { "connection #{id} disconnected" }
      end
      
      private
      def receive_data
        data = @socket.recv_nonblock RECV_MAX rescue nil
        return unless data
        if data.length < 1
          info { "connection #{id} received eof" }
          @client_disconnected = true
          disconnect
        else
          debug { "connection #{id} recieved new data (#{Util.strip_newlines data}), already has raw (#{Util.strip_newlines @raw})" }
          data.gsub! "_hack_newline", ""
          @raw += data unless @raw.length + data.length > RAW_MAX
        end
      end
    end
  end
end
