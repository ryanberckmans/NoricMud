
module Abilities
  POISON = ->game,attacker,defender{ poison game, attacker, defender }
  POISON_COST = 12
  POISON_CHANNEL = 0
  POISON_LAG = 0
  POISON_COOLDOWN = 20 * Combat::COMBAT_ROUND

  POISON_PER_INTERVAL = 3
  POISON_INTERVALS = 20

  class << self
    def poison( game, attacker, defender )
      q = Fiber.new do
        i = 0
        while i < POISON_INTERVALS do
          i += 1
          j = 0
          while j < Combat::COMBAT_ROUND
            j += 1
            Fiber.yield
          end
          Log::debug "poisoning #{defender.short_name}, poisoner #{attacker.short_name}", "poison"
          pov_scope do
            pov(defender) { "{!{FWA despair collar pulses softly, weakening you.\n" }
            pov(defender.room.mobs) { "{!{FWA despair collar pulses softly, weakening #{defender.short_name}.\n" }
          end
          Combat::damage( game, nil, defender, POISON_PER_INTERVAL )
        end
        Log::debug "done poisoning #{defender.short_name}, poisoner #{attacker.short_name}", "poison"
        pov_scope do
          pov(defender) { "{!{FWExhausted of magic, a despair collar evaporates from your neck.\n" }
          pov(defender.room.mobs) { "{!{FWExhausted of magic, a despair collar evaporates from #{defender.short_name}'s neck.\n" }
        end
      end

      pov_scope do
        pov(defender) { "A collar of tangible despair materializes around your neck!\n" }
        pov(defender.room.mobs) { "A collar of tangible despair materializes around #{defender.short_name}'s neck!\n" }
      end

      game.timer.add_periodic Combat::COMBAT_ROUND, ->{ poison_tick game, attacker, defender }, POISON_INTERVALS
      
      game.signal.connect :before_tick, ->{ return true if defender.dead?; q.resume; !q.alive? }
    end # end poison

    def poison_tick( game, attacker, defender )
      Log::debug "poison tick #{defender.short_name}, poisoner #{attacker.short_name}", "poison"
      pov_scope do
        pov(defender) { "{!{FWA despair collar pulses softly, weakening you.\n" }
        pov(defender.room.mobs) { "{!{FWA despair collar pulses softly, weakening #{defender.short_name}.\n" }
      end
      Combat::damage( game, nil, defender, POISON_PER_INTERVAL )
    end # end poison_tick
  end
end
