class Cooldown
  def initialize
    @cooldown = {}
  end

  def in_cooldown?( mob, ability )
    default_ability_cooldown mob, ability
    @cooldown[mob][ability] > 0
  end
  
  def add_cooldown( mob, ability, cooldown ) # cooldown in pulses
    raise unless cooldown.kind_of? Fixnum
    default_ability_cooldown mob, ability
    Log::debug "mob #{mob.short_name} added cooldown #{cooldown} to ability #{ability.to_s}", "cooldown"
    @cooldown[mob][ability] += cooldown
    @cooldown[mob][ability]
  end

  def tick
    Log::debug "start tick", "cooldown"
    @cooldown.each_key do |mob|
      @cooldown[mob].each_key do |ability|
        @cooldown[mob][ability] -= 1 unless @cooldown[mob][ability] < 1
        Log::debug "mob #{mob.short_name} reduced cooldown to #{@cooldown[mob][ability]} for ability #{ability.to_s}", "cooldown"
      end
    end
    Log::debug "end tick", "cooldown"
  end

  private  
  def default_cooldown( mob )
    raise "expected mob to be a Mob" unless mob.kind_of? Mob
    @cooldown[mob] ||= {}
  end

  def default_ability_cooldown( mob, ability )
    default_cooldown mob
    @cooldown[mob][ability] ||= 0
  end
end # class Cooldown
