class Regen
  REGEN_INTERVAL = 2 * Combat::COMBAT_ROUND
  
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
      if mob.state == PhysicalState::Resting then
        Log::debug "#{char.name} regen as resting", "regen"
        regen_hp mob, 8
        regen_energy mob, 8
      elsif mob.state == PhysicalState::Meditating then
        Log::debug "#{char.name} regen as meditating", "regen"
        regen_hp mob, 16
        regen_energy mob, 16
      else
        Log::debug "#{char.name} regen as standing", "regen"
        regen_hp mob, 2
        regen_energy mob, 2
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
