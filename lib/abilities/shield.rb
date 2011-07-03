
module Abilities
  SHIELD = ->game,attacker,defender{ shield game, attacker, defender }
  SHIELD_COST = 10
  SHIELD_CHANNEL = 0
  SHIELD_LAG = 0
  SHIELD_COOLDOWN = 25 * Combat::COMBAT_ROUND

  SHIELD_DURATION = 2 * Combat::COMBAT_ROUND
  SHIELD_CAPACITY = 30

  class << self
    def shield( game, attacker, defender )
      shield_start game, defender
    end

    def shield_start( game, defender )
      Log::debug "creating shield for #{defender.short_name}", "shield"
      cap = [SHIELD_CAPACITY]
      duration_over = false
      disconnector = defender.bind(:damage) do |event|
        event.before_success do
          if duration_over
            disconnector.call
            next
          end
          next unless event.damage > 0
          raise "expected shield to have capacity left" unless cap[0] > 0
          Log::debug "defender #{defender.short_name} shield #{cap[0]} attempting to absorb #{event.damage}", "shield"
          if cap[0] > event.damage
            cap[0] -= event.damage
            Log::debug "shield has #{cap[0]} remaining after absorbing #{event.damage}", "shield"
            event.damage = 0
            event.after_success { shield_hit game, defender }
            next
          end
          event.damage -= cap[0]
          cap[0] = 0
          Log::debug "damage reduced to #{event.damage} after breaking shield", "shield"
          event.after_success { shield_broken game, defender }
          disconnector.call
        end # event.before
      end # defender.bind :damage
      game.timer.add SHIELD_DURATION, ->{ return if cap[0] < 1; duration_over = true; shield_over game, defender }
      pov_scope do
        pov(defender) { "{@A magical shield appears around you.\n" }
        pov(defender.room.mobs) { "{@A magical shield appears around #{defender.short_name}.\n" }
      end
    end

    def shield_hit( game, defender )
      pov_scope do
        pov(defender) { "{!{FCYour magical shield flares brightly as it absorbs the damage!\n" }
        pov(defender.room.mobs) { "{!{FC#{defender.short_name}'s magical shield flares brightly as it absorbs the damage!\n" }
      end
    end

    def shield_broken( game, defender )
      pov_scope do
        pov(defender) { "{!{FCYour magical shield shatters after partially absorbing the damage!\n" }
        pov(defender.room.mobs) { "{!{FC#{defender.short_name}'s magical shield shatters after partially absorbing the damage!\n" }
      end
    end

    def shield_over( game, defender )
      pov_scope do
        pov(defender) { "{@Your magical shield dissipates.\n" }
        pov(defender.room.mobs) { "{@#{defender.short_name}'s magical shield dissipates.\n" }
      end
    end
  end
end
