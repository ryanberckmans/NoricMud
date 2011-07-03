module PhysicalState
  class Meditating
    MEDITATE_LAG = 60
    
    class << self
      def to_s
        "Meditating"
      end

      def damage_handler( game, mob )
        disconnect = mob.bind(:damage) do |e|
          e.before_success do
            if mob.state == PhysicalState::Meditating and e.damage > 0
              disconnect.call
              pov_scope do
                pov(mob) { "{!{FRYou take {@{FR*massively*{! increased damage while meditating!\n" }
                pov(mob.room.mobs) { "{!{FR#{mob.short_name} takes {@{FR*massively*{! increased damage while meditating!\n"}
              end
              pov_scope do
                pov(mob) { "{@You cease meditating as your concentration fails.\n" }
              end
              PhysicalState.transition game, mob, PhysicalState::Resting
            end # if damaged and meditating
          end # before_success
        end # bince_once
      end # damage_handler

      def on_enter( game, mob )
        Log::debug "mob #{mob.short_name} entered #{to_s}", "state"
        game.add_lag mob, MEDITATE_LAG
        game.lag_recovery_action mob, ->{
          PhysicalState.transition game, mob, PhysicalState::Resting if mob.state == PhysicalState::Meditating
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
