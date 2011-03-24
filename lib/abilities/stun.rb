
module Abilities
  STUN = ->game,attacker,defender{ stun game, attacker, defender }
  STUN_COST = 20
  STUN_CHANNEL = 0
  STUN_LAG = 2 * Combat::COMBAT_ROUND
  STUN_COOLDOWN = 0
  STUN_DAMAGE = 5
  STUN_TARGET_LAG = 2 * Combat::COMBAT_ROUND
  class << self
    def stun( game, attacker, defender )
      pov_scope do
        pov(attacker) { "A bolt of red-orange light leaps from your hand and stuns #{defender.short_name}!\n" }
        pov(defender) { "A bolt of red-orange light leaps from #{attacker.short_name}'s hand and stuns you!\n" }
        pov(attacker.room.mobs) { "A bolt of red-orange light leaps from #{attacker.short_name}'s hand and stuns #{defender.short_name}!\n" }
      end
      ability_damage game, attacker, defender, STUN_DAMAGE
      game.add_lag defender, STUN_TARGET_LAG
    end
  end
end
