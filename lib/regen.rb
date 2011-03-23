class Regen
  REGEN_INTERVAL = 5 * Combat::COMBAT_ROUND
  
  def initialize( game )
    @game = game
    @ticks = 0
  end

  def tick
    @ticks += 1
    return if @ticks < REGEN_INTERVAL
    @ticks = 0
    Log::debug "regenerating all charaters", "regen"
    @game.all_characters.each do |char|
      mob = char.mob
      Log::debug "regenerating #{char.name}", "regen"
      case mob.state.class
      when PhysicalState::Standing.class then
        regen_hp mob, 5
        regen_energy mob, 5
      else
        Log::debug "state not found #{char.name}", "regen"
        raise "state not found", "regen"
      end
    end
  end

  private
  def regen_hp( mob, hp )
    Log::debug "regen hp #{mob.short_name}", "regen"
    Combat::damage @game, nil, mob, hp * -1
  end

  def regen_energy( mob, energy )
    Log::debug "regen energy #{mob.short_name}", "regen"
    mob.energy += energy
    mob.energy = mob.energy_max if mob.energy > mob.energy_max
  end
end # class Regen
