
module Abilities
  NUKE = ->game,attacker,defender{ nuke game, attacker, defender }
  NUKE_COST = 15
  NUKE_CHANNEL = Combat::COMBAT_ROUND
  NUKE_LAG = Combat::COMBAT_ROUND
  NUKE_COOLDOWN = 5 * Combat::COMBAT_ROUND
  NUKE_DAMAGE = 50
  class << self
    def nuke( game, attacker, defender )
      pov_scope do
        pov(attacker) { "{@A jet of malicious green light surges forth from your hand and strikes #{defender.short_name} in the chest.\n" }
        pov(defender) { "{@A jet of malicious green light surges forth from #{attacker.short_name}'s hand and strikes you in the chest.\n" }
        pov(attacker.room.mobs) { "{@A jet of malicious green light surges forth from #{attacker.short_name}'s hand and strikes #{defender.short_name} in the chest.\n" }
      end
      ability_damage game, attacker, defender, NUKE_DAMAGE
    end
  end
end
