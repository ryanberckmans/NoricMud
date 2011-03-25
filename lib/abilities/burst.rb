
module Abilities
  BURST = ->game,attacker,defender{ burst game, attacker, defender }
  BURST_COST = 5
  BURST_CHANNEL = 0
  BURST_LAG = 1 * Combat::COMBAT_ROUND
  BURST_COOLDOWN = 0
  BURST_DAMAGE = 15

  class << self
    def burst( game, attacker, defender )
      pov_scope do
        pov(attacker) { "You scorch #{defender.short_name} with a wave of blue fire!\n" }
        pov(defender) { "#{attacker.short_name} scorches you with a wave of blue fire!\n" } 
        pov(attacker.room.mobs) { "#{attacker.short_name} scorches #{defender.short_name} with a wave of blue fire!\n" } 
      end
      ability_damage game, attacker, defender, BURST_DAMAGE
    end
  end
end
