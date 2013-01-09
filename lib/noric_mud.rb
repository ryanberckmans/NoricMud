require 'thread'

require_relative 'noric_mud/util'
require_relative 'noric_mud/log'
require_relative 'noric_mud/easy_class_log'
require_relative 'noric_mud/network/server'

module NoricMud
  extend EasyClassLog
  
  LOG_LEVEL = Logger::DEBUG
  TICK_DURATION = 0.125 # in seconds
  
  class << self
    def run
      raise "NoricMud already running" if @running
      @running = true
      log = Log.new Log::create_logger(ENV['RAILS_ENV'], LOG_LEVEL)
      Log.default = log      
      info { "============================== booting ==============================" }
      info { "instantiating core components" }

      server = Network::Server.new

      begin
        tick_loop do
          server.tick
        end
      ensure
        server.shutdown
        log.shutdown
      end
    end

    def tick_loop
      info { "starting tick loop" }
      begin
        tick_number = 0
        while true
          tick_start = Time.now
          debug { "start tick #{tick_number}" }
          yield
          tick_duration = Time.now - tick_start
          time_remaining = [0,TICK_DURATION - tick_duration].max
          info { "metrics.tick #{tick_number},duration,#{"%4.6f" % tick_duration},capacity%,#{"%4.6f" % (tick_duration / TICK_DURATION * 100)},sleeping,#{"%4.6f" % time_remaining}" }
          debug { "end tick #{tick_number}" }
          sleep time_remaining
          tick_number += 1
        end
      rescue Exception => e
        fatal { Util::dump_exception e }
      end
    end

    # Determine the current room of an object.
    # Could be nil if object is detached.
    # Could be nil if the object is a zone or something without a Room as an ancestor
    def room
    end
    
    @@queue = Queue.new

    # push block onto queue for asynchronous execution
    def async &block
      @@queue.push block if block_given?
      nil
    end

    def clear_async_queue
      @@queue.clear
      nil
    end

    def start_async_thread
      @@thread ||= Thread.new do
        while true
          block = @@queue.pop
          block.call
        end
      end
      nil
    end    
  end
end
