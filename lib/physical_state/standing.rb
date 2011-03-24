module PhysicalState
  class Standing
    @@commands = AbbrevMap.new
    @@commands.add "stand", ->game,mob,rest,match { game.send_msg mob, "{!{FGYou are already standing.\n" }
    @@commands.add "rest", ->game,mob,rest,match {
      pov_scope do
        pov(mob) { "{!{FGYou sit down and rest your tired bones.\n" }
        pov(mob.room.mobs) { "{!{FG#{mob.short_name} sits down and rests his tired bones.\n" }
      end
      PhysicalState::transition game, mob, PhysicalState::Resting
    }
    
    class << self
      STANDING_CMDS_PRIORITY = 1
      
      def to_s
        "" # Standing is special in that its string is epsilon "is here", not "is standing here"
      end

      def on_enter( game, mob )
        Log::debug "mob #{mob.short_name} entered standing", "state"
        game.mob_commands.add_cmd_handler mob, @@commands, STANDING_CMDS_PRIORITY
      end

      def on_exit( game, mob )
        Log::debug "mob #{mob.short_name} exited standing", "state"
        game.mob_commands.remove_cmd_handler mob, @@commands
      end
    end # end class << self
  end
end
