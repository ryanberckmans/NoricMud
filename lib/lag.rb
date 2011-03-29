class Lag
  def initialize
    @lag = {}
    @actions = {}
  end

  def lagged?( mob )
    default_lag mob
    @lag[mob] > 0
  end
  
  def lag( mob )
    default_lag mob
    @lag[mob]
  end

  def recovery_action( mob, action )
    default_lag mob
    raise "expected mob not to have an action" if @actions.key? mob
    Log::debug "set recovery action for #{mob.short_name}", "lag"
    @actions[mob] = action
    nil
  end

  def add_lag( mob, lag ) # lag in pulses
    raise "expected lag to be an integer" unless lag.kind_of? Fixnum
    default_lag mob
    @lag[mob] += lag
    Log::debug "added #{lag} to #{mob.short_name}", "lag"
    @lag[mob]
  end

  def tick
    Log::debug "start tick", "lag"
    @lag.each_key do |mob|
      if @lag[mob] > 0
        @lag[mob] -= 1
        if @lag[mob] < 1
          Log::debug "mob #{mob.short_name} recovered from lag", "lag"
          @actions[mob].call if @actions[mob]
          @actions.delete mob
        end
        Log::debug "mob #{mob.short_name} has lag #{@lag[mob]}", "lag"
      end
    end
    Log::debug "end tick", "lag"
  end

  private  
  def default_lag( mob )
    raise "expected mob to be a Mob" unless mob.kind_of? Mob
    @lag[mob] ||= 0
  end
end # class Lag
