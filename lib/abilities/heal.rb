
module Abilities
  HEAL = ->game,attacker,defender{ heal game, attacker, defender }
  HEAL_COST = 20
  HEAL_CHANNEL = 0
  HEAL_LAG = Combat::COMBAT_ROUND
  HEAL_COOLDOWN = 20 * Combat::COMBAT_ROUND
  class << self
    def heal( game, attacker, defender )
      if attacker == defender
        pov_scope do
          pov(attacker) { "A bright aura envelops you, healing your wounds!\n" }
          pov(attacker.room.mobs) { "A bright aura envelops #{attacker.short_name}, healing his wounds!\n"}
        end
      else
        pov_scope do
          pov(attacker) { "You touch #{defender.short_name} and a bright aura envelops them, healing their wounds!\n" }
          pov(defender) { "#{attacker.short_name} touches you and a bright aura envelops you, healing your wounds!\n" }
          pov(attacker.room.mobs) { "#{attacker.short_name} touches #{defender.short_name} and a bright aura envelops him, healing his wounds!\n"}
        end
      end
      Combat::damage( game, nil, defender, (defender.hp_max * -0.5).to_i )
    end
  end
end
