
module Driver
  class Signal
    def initialize
      @signals = {}
    end

    def fire( signal, *args )
      Log::debug "firing #{signal.to_s}", "signal"
      default_signal signal
      @signals[signal].delete_if do |receiver|
        Log::debug "calling receiver #{receiver.to_s}", "signal"
        if receiver.call(*args)
          Log::debug "removing #{receiver.to_s} from signal #{signal.to_s}; receiver returned true", "signal"
          true
        else
          false
        end
      end
      Log::debug "done firing #{signal.to_s}", "signal"
      nil
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
