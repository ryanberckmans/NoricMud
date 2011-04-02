
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
      shield_callback = ->dmg{
        return true if duration_over
        return false unless dmg[:receiver] == defender
        return false if dmg[:amount] < 1
        raise "expected shield to have capacity left" unless cap[0] > 0
        Log::debug "defender #{defender.short_name} shield #{cap[0]} attempting to absorb #{dmg.to_s}", "shield"
        if cap[0] > dmg[:amount]
          cap[0] -= dmg[:amount]
          Log::debug "shield has #{cap[0]} remaining after absorbing #{dmg[:amount]}", "shield"
          dmg[:amount] = 0
          shield_hit game, defender
          return false
        end
        dmg[:amount] -= cap[0]
        cap[0] = 0
        Log::debug "damage reduced to #{dmg[:amount]} after breaking shield", "shield"
        shield_broken game, defender
        return true
      }
      game.signal.connect :damage, shield_callback
      game.timer.add SHIELD_DURATION, ->{ return if cap[0] < 1; duration_over = true; shield_over game, defender }
      pov_scope do
        pov(defender) { "{@A magical shield appears around you.\n" }
        pov(defender.room.mobs) { "{@A magical shield appears around #{defender.short_name}.\n" }
      end
    end

    def shield_hit( game, defender )
      pov_scope do
        pov(defender) { "{!{FCYour magical shield flares brightly as it absorbs damage!\n" }
        pov(defender.room.mobs) { "{!{FC#{defender.short_name}'s magical shield flares brightly as it absorbs damage!\n" }
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
