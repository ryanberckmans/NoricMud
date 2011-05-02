
module Driver
  class Signal
    class Connector
      def initialize( proc, condition_proc=nil )
        @proc = proc
        @condition_proc = condition_proc
        @disconnect_proc = nil
      end

      def fire(*args)
        begin
          if @condition_proc
            @proc.call(*args) if @condition_proc.call(*args)
          else
            @proc.call(*args)
          end
        rescue Disconnect => e
          Log::debug "callback called disconnect", "signal"
          self.disconnect
          e.resume
        end
      end

      def connected?
        @disconnect_proc != nil
      end

      def disconnect=( disconnect_proc )
        @disconnect_proc = disconnect_proc
      end
      
      def disconnect
        raise "Connector not connected" unless connected?
        @disconnect_proc.call
        @disconnect_proc = nil
      end
    end # Connector

    def initialize
      @signals = {}
    end

    def fire( signal, *args )
      Log::debug "firing #{signal.to_s}", "signal"
      default_signal signal
      @signals[signal].each do |connector|
        Log::debug "calling connector #{connector.to_s}", "signal"
        connector.fire(*args)
      end
      Log::debug "done firing #{signal.to_s}", "signal"
      nil
    end

    def add_connector( signal, connector )
      Log::debug "adding connector #{connector.to_s} to signal #{signal.to_s}", "signal"
      raise "expected connector to be disconnected" if connector.connected?
      default_signal signal
      connector.disconnect = ->{
        @signals[signal].delete connector
        Log::debug "signal disconnect proc, removed #{connector.to_s} from signal #{signal.to_s}", "signal"
      }
      @signals[signal] << connector
      nil
    end

    def connect( signal, proc, condition_proc=nil)
      Log::debug "connecting #{signal.to_s} to #{proc.to_s}", "signal"
      connector = Connector.new proc, condition_proc
      add_connector signal, connector
      connector
    end

    def self.disconnect
      Util.resumption_exception Disconnect.new
    end

    private
    class Disconnect < Exception
    end
    
    def default_signal( signal )
      @signals[signal] ||= []
    end
  end
end
