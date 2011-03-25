
module Abilities
  PITTER = ->game,attacker,defender{ pitter game, attacker, defender }
  PITTER_COST = 1
  PITTER_CHANNEL = 0
  PITTER_LAG = (0.5 * Combat::COMBAT_ROUND).to_i
  PITTER_COOLDOWN = 0
  PITTER_DAMAGE = 5

  class << self
    def pitter( game, attacker, defender )
      pov_scope do
        pov(attacker) { "#{defender.short_name} staggers under the sizzling impact of your energy sphere!\n" }
        pov(defender) { "You stagger under the sizzling impact of #{attacker.short_name}'s energy sphere!\n" }
        pov(attacker.room.mobs) { "#{defender.short_name} staggers under the sizzling impact of #{attacker.short_name}'s energy sphere!\n" }
      end
      ability_damage game, attacker, defender, PITTER_DAMAGE
    end
  end
end
