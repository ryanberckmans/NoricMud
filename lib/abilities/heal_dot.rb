
module Abilities
  HEAL_DOT = ->game,attacker,defender{ heal_dot game, attacker, defender }
  HEAL_DOT_COST = 10
  HEAL_DOT_CHANNEL = 0
  HEAL_DOT_LAG = 0
  HEAL_DOT_COOLDOWN = 15 * Combat::COMBAT_ROUND

  HEAL_PER_INTERVAL = 5
  HEAL_INTERVALS = 10

  class << self
    def heal_dot( game, attacker, defender )
      q = Fiber.new do
        i = 0
        while i < HEAL_INTERVALS do
          i += 1
          j = 0
          while j < Combat::COMBAT_ROUND
            j += 1
            Fiber.yield
          end
          Log::debug "healing #{defender.short_name}, healer #{attacker.short_name}", "healdot"
          pov_scope do
            pov(defender) { "{!{FWA rejuvenation bracelet pulses softly, healing your wounds.\n" }
            pov(defender.room.mobs) { "{!{FWA rejuvenation bracelet pulses softly, healing #{defender.short_name}'s wounds.\n" }
          end
          Combat::damage( game, nil, defender, -1 * HEAL_PER_INTERVAL )
        end
        Log::debug "done healing #{defender.short_name}, healer #{attacker.short_name}", "healdot"
        pov_scope do
          pov(defender) { "{!{FWExhausted of magic, a rejuvenation bracelet evaporates from your wrist.\n" }
          pov(defender.room.mobs) { "{!{FWExhausted of magic, a rejuvenation bracelet evaporates from #{defender.short_name}'s wrist.\n" }
        end
      end

      pov_scope do
        pov(defender) { "A bracelet of rejuvenating energy materializes around your wrist!\n" }
        pov(defender.room.mobs) { "A bracelet of rejuvenating energy materializes around #{defender.short_name}'s wrist!\n" }
      end
      game.signal.connect :before_tick, ->{ return true if defender.dead?; q.resume; !q.alive? }
    end
  end
end
