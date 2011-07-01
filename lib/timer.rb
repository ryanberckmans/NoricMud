
class Timer
  def initialize( game )
    @tick = 0
    @timers = {}
    game.bind(:after_tick) { tick }
  end

  def add( length, tick_proc, options = {} )
    add_periodic( length, tick_proc, options.merge({periods:1}) )
  end

  def add_periodic( length, tick_proc, options = {})
    raise "length should be Natural" unless length > 0
    add_timer @tick+length, OpenStruct.new({length:length, tick_proc:tick_proc, periods:0}.merge(options)) # 0 signifies infinite periods
  end

  def self.stop
    Util.resumption_exception StopTimer.new
  end

  private
  class StopTimer < Exception
  end
  
  def add_timer( tick, struct )
    @timers[tick] ||= []
    @timers[tick] << struct
    Log::debug "added timer, #{struct.to_s}", "timer"
    nil
  end
  
  def tick
    @tick += 1
    Log::debug "tick #{@tick} began", "timer"    
    if @timers.key? @tick
      @timers[@tick].each do |timer|
        Log::debug "calling timer #{timer.to_s}", "timer"
        begin
          timer.tick_proc.call
        rescue StopTimer => e
          timer.periods = 1
          Log::debug "timer called Timer::stop, #{timer.to_s}", "timer"
          e.resume
        end
        Log::debug "done calling timer tick_proc #{timer.to_s}", "timer"
        if timer.periods == 1 # this period is the last period
          if timer.stop
            Log::debug "timer had a stop tick_proc, calling it; #{timer.to_s}", "timer"
            timer.stop.call
          end
        else
          Log::debug "scheduling timer repeat", "timer"
          timer.periods -= 1 if timer.periods > 1
          add_timer @tick+timer.length, timer
        end
      end
      @timers.delete @tick
    end
    Log::debug "tick #{@tick} ended", "timer"    
  end
end
