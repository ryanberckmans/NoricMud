
module Abilities
  HEAL_DOT = ->game,attacker,defender{ heal_dot game, attacker, defender }
  HEAL_DOT_COST = 10
  HEAL_DOT_CHANNEL = 0
  HEAL_DOT_LAG = 0
  HEAL_DOT_COOLDOWN = 15 * Combat::COMBAT_ROUND

  HEAL_DOT_DAMAGE = -10
  HEAL_DOT_TICKS = 5
  HEAL_DOT_TICK_INTERVAL = 2 * Combat::COMBAT_ROUND

  class << self
    def heal_dot( game, attacker, defender )
      heal_dot_start game, attacker, defender
      game.timer.add_periodic HEAL_DOT_TICK_INTERVAL, ->{ heal_dot_tick game, attacker, defender }, { periods:HEAL_DOT_TICKS, stop:->{ heal_dot_stop game, attacker, defender } }
    end

    def heal_dot_start( game, attacker, defender )
      Log::debug "begin healing #{defender.short_name}, healer #{attacker.short_name}", "healdot"
      pov_scope do
        pov(defender) { "{@{FGA bracelet of rejuvenating energy materializes around your wrist!\n" }
        pov(defender.room.mobs) { "{@A bracelet of rejuvenating energy materializes around #{defender.short_name}'s wrist!\n" }
      end
    end
    
    def heal_dot_stop( game, attacker, defender )
      Log::debug "done healing #{defender.short_name}, healer #{attacker.short_name}", "healdot"
      pov_scope do
        pov(defender) { "{@Exhausted of magic, a rejuvenation bracelet evaporates from your wrist.\n" }
        pov(defender.room.mobs) { "{@Exhausted of magic, a rejuvenation bracelet evaporates from #{defender.short_name}'s wrist.\n" }
      end
    end
    
    def heal_dot_tick( game, attacker, defender )
      Log::debug "tick healing tick #{defender.short_name}, heal_doter #{attacker.short_name}", "healdot"
      pov_scope do
        pov(defender) { "{@{FGA rejuvenation bracelet pulses softly, healing your wounds.\n" }
        pov(defender.room.mobs) { "{@A rejuvenation bracelet pulses softly, healing #{defender.short_name}'s wounds.\n" }
      end
      Combat::damage( game, nil, defender, HEAL_DOT_DAMAGE )
    end
  end
end
