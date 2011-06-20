
module Abilities
  REFLECT = ->game,attacker,defender{ reflect game, attacker, defender }
  REFLECT_COST = 25
  REFLECT_CHANNEL = 0
  REFLECT_LAG = 0
  REFLECT_COOLDOWN = 100 * Combat::COMBAT_ROUND

  REFLECT_DURATION = 10 * Combat::COMBAT_ROUND
  REFLECT_CAPACITY = 30

  class << self
    def reflect( game, attacker, defender )
      reflect_start game, defender
    end

    def reflect_start( game, defender )
      Log::debug "creating reflect for #{defender.short_name}", "reflect"
      reflected = false
      reflect_callback = ->spell{
        Log::debug "defender #{defender.short_name} reflecting spell", "reflect"
        caster = spell[:caster]
        reflected = true
        pov_scope do
          t =  "{!{FCThe spell rebounds off the whirling ruby energy surrounding "
          pov(defender) { t + "you!\n" }
          pov(defender.room.mobs) { t + "#{defender.short_name}!\n" }
        end
        spell[:target] = spell[:caster]
        Driver::Signal::disconnect
      }
      connector = game.signal.connect :spell, reflect_callback, ->spell{ spell[:target] == defender && spell[:caster] != defender }
      game.timer.add REFLECT_DURATION, ->{ return if reflected; connector.disconnect; reflect_over game, defender }
      pov_scope do
        pov(defender) { "{@A trellis of reflective ruby energy winks into existence around you.\n" }
        pov(defender.room.mobs) { "{@A trellis of reflective ruby energy winks into existence around #{defender.short_name}.\n" }
      end
    end

    def reflect_over( game, defender )
      pov_scope do
        pov(defender) { "{@Your reflective energy disappears as it bursts into ruby mist.\n" }
        pov(defender.room.mobs) { "{@#{defender.short_name}'s reflective energy disappears as it bursts into ruby mist.\n" }
      end
    end
  end
end