module PhysicalState
  class Meditating
    MEDITATE_LAG = 60
    
    class << self
      def to_s
        "Meditating"
      end

      def damage_handler( game, mob )
        mob.meditating_damage_handler ||= mob.bind(:damage) do |e|
          e.before_success do
            next unless mob.state == Meditating
            e.damage = (e.damage * 3).to_i if e.damage > 0
            Log::debug "amplified damage to #{e.damage} (target #{mob.short_name}, damager #{e.damager ? e.damager : ""}", "meditate"
          end
          e.after_success do
            next unless mob.state == Meditating
            if e.damage > 0
              pov_scope do
                pov(mob) { "{!{FRYou take {@{FR*massively*{! increased damage while meditating!\n" }
                pov(mob.room.mobs) { "{!{FR#{mob.short_name} takes {@{FR*massively*{! increased damage while meditating!\n"}
              end
            end
            if e.damage > -1 and game.combat.engaged? mob
              pov_scope do
                pov(mob) { "{@You jump to your feet as you're attacked!\n" }
                pov(mob.room.mobs) { "{@#{mob.short_name} jumps to his feet as he's attacked!\n" }
              end
              PhysicalState::transition game, mob, Standing
            elsif e.damage > 0
              pov_scope do
                pov(mob) { "{@You cease meditating as your concentration fails.\n" }
              end
              PhysicalState.transition game, mob, Resting
            end
          end
        end
      end # damage_handler

      def on_enter( game, mob )
        Log::debug "mob #{mob.short_name} entered #{to_s}", "state"
        game.add_lag mob, MEDITATE_LAG
        game.lag_recovery_action mob, ->{
          PhysicalState.transition game, mob, Resting if mob.state == Meditating
        }
        damage_handler game, mob
        pov_scope do
          pov(mob) { "{@You meditate for awhile....\n" }
          pov(mob.room.mobs) { "{@#{mob.short_name} began meditating.\n" }
        end
      end

      def on_exit( game, mob )
        Log::debug "mob #{mob.short_name} exited #{to_s}", "state"
      end
    end # end class << self
  end
end
