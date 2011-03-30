module PhysicalState
  class Dead
    SIGNAL = :dead
    DEAD_TIME = 15 # seconds
    CMDS_PRIORITY = 100

    @@commands = AbbrevMap.new nil, ->(game, mob, rest, match) { game.send_msg mob, "{@Lie still; you are dead.\n" }
    
    class << self
      def to_s
        "Dead"
      end

      def on_enter( game, mob )
        Log::debug "mob #{mob.short_name} entered dead", "state"
        game.combat.disengage mob if game.combat.engaged? mob
        pov_scope do
          pov(mob) { "{@\nYou're {!{FRDEAD!!{@ It is strangely {!{FCpainless{@.\n" }
          pov(mob.room.mobs) { "{!{FR#{mob.short_name} is DEAD!!\n" }
          pov(mob.room.adjacent_mobs) { "{@You hear a blood-curdling death cry!\n" }
        end
        mob.hp = 0
        game.mob_commands.add_cmd_handler mob, @@commands, CMDS_PRIORITY
        game.signal.fire SIGNAL, mob
        start_time = Time.now
        game.signal.connect :after_tick, ->{ PhysicalState::transition game, mob, PhysicalState::Resting if Time.now - start_time > DEAD_TIME }
      end

      def on_exit( game, mob )
        Log::debug "mob #{mob.short_name} exited dead", "state"
        pov_scope do
          pov(mob) { "{@Your lifeless body implodes in a shower of sparks.\n" }
          pov(mob.room.mobs) { "{@The lifeless husk that was once #{mob.short_name} implodes in a shower of sparks.\n" }
        end
        game.move_to( mob, game.respawn_room )
        Combat::restore mob
        pov_scope do
          pov(mob) { "{@You wake up with a splitting headache, but your wounds are healed.\n" }
          pov(mob.room.mobs) { "{@Whoooooosh! {!{FY#{mob.short_name}{@ materializes.\n" }
        end
        CoreCommands::look game, mob
        game.mob_commands.remove_cmd_handler mob, @@commands
      end
    end # end class << self
  end
end
