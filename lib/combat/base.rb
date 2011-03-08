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
      @in_combat = {}

      @in_combat_cmds = AbbrevMap.new
      @in_combat_cmds.add "north", ->(game, mob, rest, match) { game.send_msg mob, "You're busy fighting!!\n" }
      @in_combat_cmds.add "south", ->(game, mob, rest, match) { game.send_msg mob, "You're busy fighting!!\n" }
      @in_combat_cmds.add "east", ->(game, mob, rest, match) { game.send_msg mob, "You're busy fighting!!\n" }
      @in_combat_cmds.add "west", ->(game, mob, rest, match) { game.send_msg mob, "You're busy fighting!!\n" }
      @in_combat_cmds.add "up", ->(game, mob, rest, match) { game.send_msg mob, "You're busy fighting!!\n" }
      @in_combat_cmds.add "down", ->(game, mob, rest, match) { game.send_msg mob, "You're busy fighting!!\n" }
      @in_combat_cmds.add "kill", ->(game, mob, rest, match) { game.send_msg mob, "You're already fighting!!\n" }
      @in_combat_cmds.add "fight random", ->(game, mob, rest, match) { game.send_msg mob, "You're already fighting someone random!!\n" }
      @game.mob_commands.add_default_cmd_handler ->(mob){ @in_combat_cmds if in_combat? mob }, COMBAT_COMMANDS_HANDLER_PRIORITY + 2
    end

    def tick
      # combat.tick should be called after player commands are processed, so new fights happen this tick
      @game.all_characters.each do |char|
        mob = char.mob
        mob.attack_cooldown -= 1
        mob.attack_cooldown = 0 if mob.attack_cooldown < 0
      end
      Log::info "start tick", "combat"
      @in_combat.delete_if do |attacker,defender|
        fight_over = attacker.room != defender.room
        Log::debug "fight between #{attacker.short_name}, #{defender.short_name} is over", "combat" if fight_over
        tick_fight attacker, defender unless fight_over
        fight_over
      end
      Log::info "end tick", "combat"
    end

    def target( mob )
      raise "expected mob to be in combat" unless in_combat? mob
      @in_combat[mob]
    end

    def in_combat?( mob )
      raise "expected mob to be a Mob" unless mob.kind_of? Mob
      @in_combat.key? mob
    end

    def start_combat( attacker, defender )
      raise "expected attacker to be a Mob" unless attacker.kind_of? Mob
      raise "expected defender to be a Mob" unless defender.kind_of? Mob
      raise "expected attacker to differ from defender" if attacker == defender
      raise "expected attacker to not be fighting" if in_combat? attacker
      @in_combat[attacker] = defender
      Log::debug "#{attacker.short_name} starting fighting #{defender.short_name}", "combat"
      start_combat( defender, attacker ) unless in_combat? defender
    end

    def end_combat( attacker )
      raise "expected attacker to be a Mob" unless attacker.kind_of? Mob
      raise "expected attacker to be fighting" unless in_combat? attacker
      @in_combat.delete attacker
      Log::debug "#{attacker.short_name} stopped fighting", "combat"
    end

    private
    def tick_fight( attacker, defender )
      Log::debug "ticking fight, attacker #{attacker.short_name}, defender #{defender.short_name}", "combat"
      raise "expected attacker to have positive hp" unless attacker.hp > 0
      raise "expected defender to have positive hp" unless defender.hp > 0
      if attacker.attack_cooldown < 1
        attacker.attack_cooldown = attacker.attack_cooldown_max
        if Random.new.rand(1..2) > 1
          melee_hit attacker, defender
        else
          melee_miss attacker, defender
        end
      end
    end
    
    def melee_miss( attacker, defender )
      Log::debug "#{attacker.short_name} melee missed #{defender.short_name}", "combat"
      pov_scope do
        pov(attacker) { "{!{FGYour slash misses #{defender.short_name}.\n" }
        pov(defender) { "{!{FG#{attacker.short_name}'s slash misses you.\n" }
        pov(attacker.room.mobs) { "{!{FG#{attacker.short_name}'s slash misses #{defender.short_name}.\n" }
      end
    end
    
    def melee_hit( attacker, defender )
      Log::debug "#{attacker.short_name} melee hit #{defender.short_name}", "combat"
      pov_scope do
        pov(attacker) { "{!{FGYour slash decimates #{defender.short_name}!\n" }
        pov(defender) { "{!{FG#{attacker.short_name}'s slash decimates you!\n" }
        pov(attacker.room.mobs) { "{!{FG#{attacker.short_name}'s slash decimates #{defender.short_name}!\n" }
      end
      Combat::damage @game, defender, 20
    end
  end # end Public

  add_cmd "kill", ->game,mob,rest,match { kill game, mob, rest }
  add_cmd "kill random", ->game,mob,rest,match { green_beam game, mob }
  add_cmd "fight random", ->game,mob,rest,match { kill game, mob, mob.room.mobs.sample.short_name }

  def self.damage( game, mob, amount )
    raise "expected mob to be a Mob" unless mob.kind_of? Mob
    raise "expected amount to be an Integer" unless amount.kind_of? Fixnum
    mob.hp -= amount
    death game, mob if mob.hp < 1
  end

  def self.kill( game, attacker, target )
    raise "expected attacker to be a Mob" unless attacker.kind_of? Mob
    raise "expected target to be a String" unless target.kind_of? String
    if target.empty?
      game.send_msg attacker, "Yes! Sate your bloodlust!! But on who?\n"
      return
    end
    attacker.room.mobs.each do |mob_in_room|
      if mob_in_room.short_name =~ Regexp.new( target, Regexp::IGNORECASE) and attacker != mob_in_room
        game.combat.start_combat attacker, mob_in_room
        return
      end
    end
    game.send_msg attacker, "They aren't here.\n"
  end
  
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
    damage( game, dies, dies.hp )
  end

  def self.restore( mob )
    mob.hp = mob.hp_max
    mob.energy = mob.energy_max
  end

  def self.death( game, mob )
    Log::info "#{mob.short_name} died", "combat"
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


