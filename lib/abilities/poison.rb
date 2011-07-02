
module Abilities
  POISON = ->game,attacker,defender{ poison game, attacker, defender }
  POISON_COST = 12
  POISON_CHANNEL = 0
  POISON_LAG = 0
  POISON_COOLDOWN = 20 * Combat::COMBAT_ROUND

  POISON_DAMAGE = 6
  POISON_TICKS = 10
  POISON_TICK_INTERVAL = 2 * Combat::COMBAT_ROUND

  class << self
    def poison( game, attacker, defender )
      poison_start game, attacker, defender
      poisoned = true
      bind_disconnect = defender.bind_once(:dead) {
        return unless poisoned
        poisoned = false
        poison_stop game, attacker, defender
      }
      game.timer.add_periodic POISON_TICK_INTERVAL, ->{ poison_tick game, attacker, defender if poisoned }, { periods:POISON_TICKS, stop:->{ poisoned = false; bind_disconnect.call; poison_stop game, attacker, defender } }
    end

    def poison_start( game, attacker, defender )
      Log::debug "poisoning #{defender.short_name}, poisoner #{attacker.short_name}", "poison"
      pov_scope do
        pov(defender) { "{@{FRA collar of tangible despair materializes around your neck!\n" }
        pov(defender.room.mobs) { "{@A collar of tangible despair materializes around #{defender.short_name}'s neck!\n" }
      end
    end
    
    def poison_stop( game, attacker, defender )
      Log::debug "done poisoning #{defender.short_name}, poisoner #{attacker.short_name}", "poison"
      pov_scope do
        pov(defender) { "{@Exhausted of magic, a despair collar evaporates from your neck.\n" }
        pov(defender.room.mobs) { "{@Exhausted of magic, a despair collar evaporates from #{defender.short_name}'s neck.\n" }
      end
    end
    
    def poison_tick( game, attacker, defender )
      Log::debug "poison tick #{defender.short_name}, poisoner #{attacker.short_name}", "poison"
      pov_scope do
        pov(defender) { "{@{FRA despair collar pulses softly, weakening you.\n" }
        pov(defender.room.mobs) { "{@A despair collar pulses softly, weakening #{defender.short_name}.\n" }
      end
      Combat::damage( game, nil, defender, POISON_DAMAGE )
    end
  end
end
