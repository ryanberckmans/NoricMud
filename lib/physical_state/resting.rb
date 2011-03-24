module PhysicalState
  class Resting
    @@rest_cmds = AbbrevMap.new
    REST_CMDS_PRIORITY = 20
    class << self
      def to_s
        "Resting"
      end
      
      def on_enter( game, mob )
        game.mob_commands.add_cmd_handler mob, @@rest_cmds, REST_CMDS_PRIORITY
        Log::debug "mob #{mob.short_name} entered #{to_s}", "state"
      end

      def on_exit( game, mob )
        game.mob_commands.remove_cmd_handler mob, @@rest_cmds
        if game.combat.engaged? mob
          pov_scope do
            pov(mob) { "{@You jump to your feet as you're attacked!\n" }
            pov(mob.room.mobs) { "{@#{mob.short_name} jumps to his feet as he's attacked!\n" }
          end
        end
        Log::debug "mob #{mob.short_name} exited #{to_s}", "state"
      end

      private
      DISABLE_MSG = "{@You can't do that while resting.\n"
      def add_cmd( cmd, callback )
        @@rest_cmds.add cmd, callback
      end
      
      def add_disabled_cmd( cmd )
        @@rest_cmds.add cmd, ->(game, mob, rest, match) { game.send_msg mob, DISABLE_MSG }        
      end


    end # class << self
    add_cmd "rest", ->game,mob,rest,match { game.send_msg mob, "{!{FGYou are already resting.\n" }

    add_disabled_cmd "north"
    add_disabled_cmd "west"
    add_disabled_cmd "east"
    add_disabled_cmd "south"
    add_disabled_cmd "up"
    add_disabled_cmd "down"
    add_disabled_cmd "kill"
    add_disabled_cmd "flee"
    add_disabled_cmd "cast"

    add_cmd "stand", ->game,mob,rest,match {
      pov_scope do
        pov(mob) { "{!{FGYou stop resting, and stand up.\n" }
        pov(mob.room.mobs) { "{!{FG#{mob.short_name} stops resting and stands up.\n" }
      end
      PhysicalState::transition game, mob, PhysicalState::Standing
    }

  end
end
