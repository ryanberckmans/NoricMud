
class Timer
  def initialize( signal )
    @tick = 0
    @timers = {}
    signal.connect :after_tick, ->{ tick }
  end

  def add( wait, proc )
    add_periodic( wait, proc, 1 )
  end

  def add_periodic( wait, proc, cycles=0) # 0 signifies infinite cycles
    raise "wait should be Natural" unless wait > 0
    add_timer @tick+wait, OpenStruct.new({wait:wait, proc:proc, cycles:cycles})
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
    Log::debug "added timer, wait #{struct.wait.to_s}, proc #{struct.proc.to_s}, cycles #{struct.cycles.to_s}", "timer"
    nil
  end
  
  def tick
    @tick += 1
    Log::debug "tick #{@tick} began", "timer"    
    if @timers.key? @tick
      @timers[@tick].each do |timer|
        Log::debug "calling timer proc #{timer.proc.to_s}, wait #{timer.wait}, cycles #{timer.cycles}", "timer"
        begin
        timer.proc.call
        rescue StopTimer => e
          timer.cycles = 1
          Log::debug "timer called Timer::stop, proc #{timer.proc.to_s}, wait #{timer.wait}, cycles #{timer.cycles}", "timer"
          e.resume
        end
        Log::debug "done calling timer proc #{timer.proc.to_s}, wait #{timer.wait}, reptitions #{timer.cycles}", "timer"
        if timer.cycles == 1 # this cycle is the last cycle
        else
          Log::debug "scheduling timer repeat", "timer"
          timer.cycles -= 1 if timer.cycles > 1
          add_timer @tick+timer.wait, timer
        end
      end
      @timers.delete @tick
    end
    Log::debug "tick #{@tick} ended", "timer"    
  end
end
