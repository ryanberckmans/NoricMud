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
  
  add_cmd "north", ->(game, mob, rest, match) { game.exit_room(mob,mob.room.north,"north") }
  add_cmd "south", ->(game, mob, rest, match) { game.exit_room(mob,mob.room.south,"south") }
  add_cmd "up", ->(game, mob, rest, match) { game.exit_room(mob,mob.room.up,"up") }
  add_cmd "down", ->(game, mob, rest, match) { game.exit_room(mob,mob.room.down,"down") }
  add_cmd "west", ->(game, mob, rest, match) { game.exit_room(mob,mob.room.west,"west") }
  add_cmd "east", ->(game, mob, rest, match) { game.exit_room(mob,mob.room.east,"east") }
  add_cmd "say", ->game,mob,rest,match { say game, mob, rest }
  add_cmd "quit", ->(game, mob, rest, match) { quit game, mob, match }
  add_cmd "shout", ->(game, mob, rest, match) { shout(game, mob, rest) }
  add_cmd "look", ->(game, mob, rest, match) { look( game, mob ) }
  add_cmd "exits", ->(game, mob, rest, match) { exits( game, mob ) }
  add_cmd "hp", ->(game, mob, rest, match) { mob.hp -= 25; mob.hp = 1 if mob.hp < 1 }
  add_cmd "energy", ->(game, mob, rest, match) { mob.energy -= 10; mob.energy = 1 if mob.energy < 1  }
  add_cmd "flee", ->game,mob,rest,match { Combat.flee game, mob }
  add_cmd "kill", ->game,mob,rest,match { Combat.kill game, mob, rest }
  add_cmd "slay random", ->game,mob,rest,match { Combat.green_beam game, mob }
  add_cmd "kill random", ->game,mob,rest,match { Combat.kill game, mob, mob.room.mobs.sample.short_name }
end


