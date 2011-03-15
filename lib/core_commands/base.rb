files = Dir.glob Util.here "*.rb"
files.each do |f| require f end

module CoreCommands
  @commands = AbbrevMap.new
  CORE_COMMANDS_HANDLER_PRIORITY = 2
  
  def self.new( game )
    Public.new game
  end

  def self.add_cmd( cmd, callback )
    @commands.add cmd, callback
  end

  def self.commands
    @commands
  end

  class Public
    def initialize( game )
      @game = game
      @game.mob_commands.add_default_cmd_handler CoreCommands::commands, CORE_COMMANDS_HANDLER_PRIORITY
    end
  end
  
  add_cmd "north", ->(game, mob, rest, match) { game.exit_room(mob,mob.room.exit[Exit::NORTH]) }
  add_cmd "south", ->(game, mob, rest, match) { game.exit_room(mob,mob.room.exit[Exit::SOUTH]) }
  add_cmd "up", ->(game, mob, rest, match) { game.exit_room(mob,mob.room.exit[Exit::UP]) }
  add_cmd "down", ->(game, mob, rest, match) { game.exit_room(mob,mob.room.exit[Exit::DOWN]) }
  add_cmd "west", ->(game, mob, rest, match) { game.exit_room(mob,mob.room.exit[Exit::WEST]) }
  add_cmd "east", ->(game, mob, rest, match) { game.exit_room(mob,mob.room.exit[Exit::EAST]) }
  add_cmd "say", ->game,mob,rest,match { say game, mob, rest }
  add_cmd "quit", ->(game, mob, rest, match) { quit game, mob, match }
  add_cmd "shout", ->(game, mob, rest, match) { shout(game, mob, rest) }
  add_cmd "look", ->(game, mob, rest, match) { look( game, mob ) }
  add_cmd "exits", ->(game, mob, rest, match) { exits( game, mob ) }
  add_cmd "flee", ->game,mob,rest,match { Combat.flee game, mob }
  add_cmd "glance", ->game,mob,rest,match { Combat.glance game, mob, rest }
  add_cmd "kill", ->game,mob,rest,match { Combat.kill game, mob, rest }
  add_cmd "slay random", ->game,mob,rest,match { Combat.green_beam game, mob }
  add_cmd "kill random", ->game,mob,rest,match { Combat.kill game, mob, mob.room.mobs.sample.short_name }
  add_cmd "who", ->game,mob,rest,match { who game, mob }
  add_cmd "help", ->game,mob,rest,match { help game, mob }
  add_cmd "commands", ->game,mob,rest,match { help game, mob }
  add_cmd "?", ->game,mob,rest,match { help game, mob }
  add_cmd "goto", ->game,mob,rest,match { goto game, mob, rest }
  add_cmd "room create", ->game,mob,rest,match { room_create game, mob, rest }
  add_cmd "room toggle id", ->game,mob,rest,match { room_toggle_show_id game, mob }
  add_cmd "room name", ->game,mob,rest,match { room_name game, mob, rest }
  add_cmd "room description", ->game,mob,rest,match { room_desc game, mob, rest }
  add_cmd "room default name", ->game,mob,rest,match { room_default_name game, mob, rest }
  add_cmd "room exit", ->game,mob,rest,match { room_exit game, mob, rest }
  add_cmd "room unexit", ->game,mob,rest,match { room_unexit game, mob, rest }
  add_cmd "room list", ->game,mob,rest,match { room_list game, mob }
  add_cmd "where", ->game,mob,rest,match { where game, mob }
  add_cmd "weapon", ->game,mob,rest,match { game.combat.weapon.weapon_cycle mob }
end
