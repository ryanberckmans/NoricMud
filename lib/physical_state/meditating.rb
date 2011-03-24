module PhysicalState
  class Meditating
    MEDITATE_LAG = 60
    
    class << self
      def to_s
        "Meditating"
      end

      def on_enter( game, mob )
        Log::debug "mob #{mob.short_name} entered #{to_s}", "state"
        game.add_lag mob, MEDITATE_LAG
        game.lag_recovery_action mob, ->{
          if mob.state == PhysicalState::Meditating
            pov_scope do
              pov(mob) { "{@You complete your meditation.\n" }
              pov(mob.room.mobs) { "{@#{mob.short_name} completes his meditation.\n" }
            end
            PhysicalState.transition game, mob, PhysicalState::Resting
          end
        }
        pov_scope do
          pov(mob) { "{@You meditate for awhile....\n" }
          pov(mob.room.mobs) { "{@#{mob.short_name} began meditating.\n" }
        end
      end

      def on_exit( game, mob )
        Log::debug "mob #{mob.short_name} exited #{to_s}", "state"
        if game.combat.engaged? mob
          pov_scope do
            pov(mob) { "{@You jump to your feet as you're attacked!\n" }
            pov(mob.room.mobs) { "{@#{mob.short_name} jumps to his feet as he's attacked!\n" }
          end
        end
      end
    end # end class << self
  end
end
