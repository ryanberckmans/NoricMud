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
    COMBAT_ROUND_TICK_INTERVAL = 12
    
    def initialize( game )
      @game = game
      @game.mob_commands.add_default_cmd_handler Combat::commands, COMBAT_COMMANDS_HANDLER_PRIORITY
      @combat_round = CombatRound.new
      @ticks_until_combat_round = COMBAT_ROUND_TICK_INTERVAL
      
      @in_combat_cmds = AbbrevMap.new
      @in_combat_cmds.add "north", ->(game, mob, rest, match) { game.send_msg mob, "You're busy fighting!!\n" }
      @in_combat_cmds.add "south", ->(game, mob, rest, match) { game.send_msg mob, "You're busy fighting!!\n" }
      @in_combat_cmds.add "east", ->(game, mob, rest, match) { game.send_msg mob, "You're busy fighting!!\n" }
      @in_combat_cmds.add "west", ->(game, mob, rest, match) { game.send_msg mob, "You're busy fighting!!\n" }
      @in_combat_cmds.add "up", ->(game, mob, rest, match) { game.send_msg mob, "You're busy fighting!!\n" }
      @in_combat_cmds.add "down", ->(game, mob, rest, match) { game.send_msg mob, "You're busy fighting!!\n" }
      @in_combat_cmds.add "quit", ->(game, mob, rest, match) { game.send_msg mob, "You haven't yet mastered the quit-while-fighting skill.\n" }
      @game.mob_commands.add_default_cmd_handler ->(mob){ @in_combat_cmds if @combat_round.engaged? mob }, COMBAT_COMMANDS_HANDLER_PRIORITY + 2
    end

    def tick
      # combat.tick should be called after player commands are processed, so new fights happen this tick
      Log::info "start tick", "combat"
      @game.all_characters.each do |char|
        mob = char.mob
        mob.attack_cooldown -= 1
        mob.attack_cooldown = 0 if mob.attack_cooldown < 0
      end
      @ticks_until_combat_round -= 1
      if @ticks_until_combat_round < 1
        @combat_round.next_round do |attacker, defender|
          3.times { Combat.melee_try @game, attacker, defender; break unless @combat_round.valid_attack? attacker }
        end
        @ticks_until_combat_round = COMBAT_ROUND_TICK_INTERVAL
      end
      Log::info "end tick", "combat"
    end

    def target_of( mob )
      @combat_round.target_of mob
    end

    def engaged?( mob )
      @combat_round.engaged? mob
    end

    def engage( attacker, defender )
      @combat_round.engage attacker, defender
    end

    def disengage( attacker )
      @combat_round.disengage attacker
    end
  end # end Public

  def self.melee_try( game, attacker, defender )
    Random.new.rand(0..1) > 0 ? melee_miss( game, attacker, defender) : melee_hit( game, attacker, defender)
  end
  
  def self.melee_miss( game, attacker, defender )
    Log::debug "#{attacker.short_name} melee missed #{defender.short_name}", "combat"
    pov_scope do
      pov(attacker) { "{!{FGYour slash misses #{defender.short_name}.\n" }
      pov(defender) { "{!{FG#{attacker.short_name}'s slash misses you.\n" }
      pov(attacker.room.mobs) { "{!{FG#{attacker.short_name}'s slash misses #{defender.short_name}.\n" }
    end
  end
  
  def self.melee_hit( game, attacker, defender )
    Log::debug "#{attacker.short_name} melee hit #{defender.short_name}", "combat"
    pov_scope do
      pov(attacker) { "{!{FGYour slash decimates #{defender.short_name}!\n" }
      pov(defender) { "{!{FG#{attacker.short_name}'s slash decimates you!\n" }
      pov(attacker.room.mobs) { "{!{FG#{attacker.short_name}'s slash decimates #{defender.short_name}!\n" }
    end
    Combat::damage game, defender, 20
  end

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
        game.combat.engage attacker, mob_in_room
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
    game.combat.disengage mob if game.combat.engaged? mob
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


