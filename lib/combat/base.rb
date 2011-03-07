files = Dir.glob Util.here "*.rb"
files.each do |f| require f end

module Combat
  @commands = AbbrevMap.new
  COMBAT_COMMANDS_HANDLER_PRIORITY = 10
  
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
      @game.mob_commands.add_default_cmd_handler Combat::commands, COMBAT_COMMANDS_HANDLER_PRIORITY
    end
  end

  add_cmd "kill random", ->game,mob,rest,match { green_beam game, mob }

  def self.green_beam( game, mob )
    dies = mob.room.mobs.sample
    if dies == mob
      pov_scope do
        pov(mob) { "A aura of malicious {!{FGgreen light{@ blossoms around you, and then implodes violently.\n" }
        pov(mob.room.mobs) { "A aura of malicious {!{FGgreen light{@ blossoms around {!{FY#{mob.short_name}{@, and then implodes violently.\n" }
      end
    else
      pov_scope do
        pov(mob) { "A jet of malicious {!{FGgreen light{@ surges forth from your hand and strikes {!{FY#{dies.short_name}{@ in the chest.\n" }
        pov(dies) { "A jet of malicious {!{FGgreen light{@ surges forth from {!{FY#{mob.short_name}'s{@ hand and strikes you in the chest.\n" }
        pov(mob.room.mobs) { "A jet of malicious {!{FGgreen light{@ surges forth from {!{FY#{mob.short_name}'s{@ hand and strikes {!{FY#{dies.short_name}{@ in the chest.\n" }
      end
    end
    death game, dies
  end

  def self.restore( mob )
    mob.hp = mob.hp_max
    mob.energy = mob.energy_max
  end

  def self.death( game, mob )
    pov_scope do
      pov(mob) { "{@\nYou're {!{FRDEAD!!{@ It is strangely {!{FCpainless{@.\n" }
      pov(mob.room.mobs) { "{!{FY#{mob.short_name}{@ is {!{FRDEAD{@!!\nThe lifeless husk that was once {!{FY#{mob.short_name}{@ implodes in a shower of sparks.\n" }
    end
    game.move_to( mob, game.respawn_room )
    restore mob
    pov_scope do
      pov(mob) { "{@You wake up with a splitting headache, but your wounds are healed.\n" }
      pov(mob.room.mobs) { "{@Whoooooosh! {!{FY#{mob.short_name}{@ materializes.\n" }
    end
    CoreCommands::look game, mob
  end
end


