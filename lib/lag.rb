class Lag
  def initialize
    @lag = {}
  end

  def lagged?( mob )
    default_lag mob
    @lag[mob] > 0
  end
  
  def lag( mob )
    default_lag mob
    @lag[mob]
  end

  def add_lag( mob, lag ) # lag in pulses
    raise unless lag.kind_of? Fixnum
    default_lag mob
    @lag[mob] += lag
    @lag[mob]
  end

  def tick
    Log::debug "start tick", "lag"
    @lag.each_key do |mob|
      @lag[mob] -= 1 unless @lag[mob] < 1
      raise "expected mob lag to be positive" if @lag[mob] < 0
      Log::debug "mob #{mob.short_name} has lag #{@lag[mob]}", "lag"
    end
  end

  private  
  def default_lag( mob )
    raise "expected mob to be a Mob" unless mob.kind_of? Mob
    @lag[mob] ||= 0
  end
end # class Lag
