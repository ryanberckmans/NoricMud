class Cooldown
  def initialize
    @cooldown = {}
    @actions = {}
  end

  def cooldowns( mob )
    default_cooldown mob
    if @cooldown[mob].size > 0
      cd = "{!{FWAbility Cooldowns:\n"
      @cooldown[mob].each_pair do |ability,cooldown|
        line = ability
        line += " " while line.length < 8
        line = "{FY" + line + "{FG - {FC" + (cooldown * TICK_DURATION).to_i.to_s + "s\n"
        cd += line
      end
    else
      cd = "{!{FWNo abilities cooling down.\n"
    end
    cd
  end

  def in_cooldown?( mob, ability )
    default_ability_cooldown mob, ability
    @cooldown[mob][ability] > 0
  end
  
  def add_cooldown( mob, ability, cooldown, recovery_action=nil ) # cooldown in pulses
    raise unless cooldown.kind_of? Fixnum
    raise "expected ability to be a String" unless ability.kind_of? String
    default_ability_cooldown mob, ability
    Log::debug "mob #{mob.short_name} added cooldown #{cooldown} to ability #{ability.to_s}", "cooldown"
    @cooldown[mob][ability] += cooldown
    @actions[mob][ability] = recovery_action if recovery_action
    nil
  end

  def tick
    Log::debug "start tick", "cooldown"
    @cooldown.each_key do |mob|
      @cooldown[mob].each_key do |ability|
        if @cooldown[mob][ability] > 0
          @cooldown[mob][ability] -= 1
          if @cooldown[mob][ability] < 1
            Log::debug "mob #{mob.short_name} finished cooling down ability #{ability.to_s}", "cooldown"
            @actions[mob][ability].call if @actions[mob][ability]
            @actions[mob].delete ability
            @cooldown[mob].delete ability
          else
            Log::debug "mob #{mob.short_name} reduced cooldown to #{@cooldown[mob][ability]} for ability #{ability.to_s}", "cooldown"
          end
        end
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
    raise "expected ability to be a String" unless ability.kind_of? String
    default_cooldown mob
    @cooldown[mob][ability] ||= 0
    @actions[mob] ||= {}
  end
end # class Cooldown
