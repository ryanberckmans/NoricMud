
module Driver
  class Signal
    class Connector
      def initialize( proc, condition_block=nil )
        @proc = proc
        @condition_block = condition_block
        @disconnect_proc = nil
      end

      def fire(*args)
        if @condition_block
          @proc.call(*args) if @condition_block.call(*args)
        else
          @proc.call(*args)
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
        @signals.remove connector
        Log::debug "signal disconnect proc, removed #{connector.to_s} from signal #{signal.to_s}", "signal"
      }
      @signals[signal] << connector
    end

    def connect( signal, proc, *filter_args )
      Log::debug "connecting #{signal.to_s} to #{proc.to_s}", "signal"
      default_signal signal
      if filter_args.size > 0
        @signals[signal] << ->*args{ return unless args == filter_args; proc.call *args }
      else
        @signals[signal] << proc
      end
      nil
    end

    def disconnect( signal, proc )
      raise "temporarily disabled; filter_args breaks delete"
      Log::debug "disconnecting #{signal.to_s} from #{proc.to_s}", "signal"
      default_signal signal
      if @signals[signal].delete proc
        Log::debug "#{signal.to_s} was found and deleted from #{proc.to_s}", "signal"
      else
        Log::error "#{signal.to_s} was not found and not deleted from #{proc.to_s}", "signal"
        raise "#{signal.to_s} was not found and not deleted from #{proc.to_s}"
      end
      nil
    end

    private
    def default_signal( signal )
      @signals[signal] ||= []
    end
  end
end
