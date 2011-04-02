files = Dir.glob Util.here "*.rb"
files.each do |f| require f end

module Combat
  COMBAT_ROUND = 12 # pulses
  
  @commands = AbbrevMap.new
  COMBAT_COMMANDS_HANDLER_PRIORITY = 50

  DAMAGE_TIER = {
    barely_touch:0,
    scratch:2,
    bruise:3,
    hit:4,
    injure:5,
    wound:7,
    draw_blood:9,
    smite:11,
    massacre:14,
    decimate:20,
    devastate:25,
    maim:30,
    mutilate:40,
    pulverise:50,
    demolish:60,
    mangle:70,
    obliterate:80,
    annihilate:90,
    horribly_maim:100,
    visciously_rend:130,
  }

  DAMAGE_COLOR_TIER = {
    DAMAGE_TIER[:barely_touch] => "{!{FW",
    DAMAGE_TIER[:draw_blood]  => "{!{FC",
    DAMAGE_TIER[:maim] => "{!{FM",
    DAMAGE_TIER[:annihilate] => "{!{FR"
  }

  DAMAGE_PERCENT_TEXT = {
    24.0 => "dismembers",
    31.0 => "eviscerates",
    51.0 => "disembowels",
    76.0 => "decapitates",
    100.0 => "kills",
  }
  
  DAMAGE_TEXT = {
    barely_touch:"barely touches",
    scratch:"scratches",
    bruise:"bruises",
    hit:"hits",
    injure:"injures",
    wound:"wounds",
    draw_blood:"draws blood from",
    smite:"smites",
    massacre:"massacres",
    decimate:"decimates",
    devastate:"devastates",
    maim:"maims",
    mutilate:"mutilates",
    pulverise:"pulverizes",
    demolish:"demolishes",
    mangle:"mangles",
    obliterate:"obliterates",
    annihilate:"annihilates",
    horribly_maim:"horribly maims",
    visciously_rend:"visciously rends",
  }
  
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
      @combat_round = CombatRound.new @game
      @ticks_until_combat_round = COMBAT_ROUND
      @weapon = Weapon.new @game
      
      @in_combat_cmds = AbbrevMap.new
      @in_combat_cmds.add "north", ->(game, mob, rest, match) { game.send_msg mob, "You're busy fighting!!\n" }
      @in_combat_cmds.add "south", ->(game, mob, rest, match) { game.send_msg mob, "You're busy fighting!!\n" }
      @in_combat_cmds.add "east", ->(game, mob, rest, match) { game.send_msg mob, "You're busy fighting!!\n" }
      @in_combat_cmds.add "west", ->(game, mob, rest, match) { game.send_msg mob, "You're busy fighting!!\n" }
      @in_combat_cmds.add "up", ->(game, mob, rest, match) { game.send_msg mob, "You're busy fighting!!\n" }
      @in_combat_cmds.add "down", ->(game, mob, rest, match) { game.send_msg mob, "You're busy fighting!!\n" }
      @in_combat_cmds.add "rest", ->(game, mob, rest, match) { game.send_msg mob, "You're busy fighting!!\n" }
      @in_combat_cmds.add "goto", ->(game, mob, rest, match) { game.send_msg mob, "You're busy fighting!!\n"}
      @in_combat_cmds.add "kill", ->(game, mob, rest, match) { game.send_msg mob, "You are already trying to kill someone!!\n" }
      @in_combat_cmds.add "weapon", ->(game, mob, rest, match) { game.send_msg mob, "You can't change weapons in combat!!\n" }
      @in_combat_cmds.add "kill random", ->(game, mob, rest, match) { game.send_msg mob, "You are already trying to kill someone random!!\n" }
      @in_combat_cmds.add "slay random", ->(game, mob, rest, match) { game.send_msg mob, "Momma always says, no slaying while fighting.\n" }
      @in_combat_cmds.add "quit", ->(game, mob, rest, match) { game.send_msg mob, "You haven't yet mastered the quit-while-fighting skill.\n" }
      @game.mob_commands.add_default_cmd_handler ->(mob){ @in_combat_cmds if @combat_round.engaged? mob }, COMBAT_COMMANDS_HANDLER_PRIORITY + 2
    end

    def weapon
      @weapon
    end

    def tick
      # combat.tick should be called after player commands are processed, so new fights happen this tick
      Log::info "start tick", "combat"
      @game.all_characters.each do |char|
        mob = char.mob
        if mob.attack_cooldown > 0
          mob.attack_cooldown -= @weapon.attack_speed(mob) / COMBAT_ROUND
          mob.attack_cooldown = 0.0 if mob.attack_cooldown < 0
          Log::debug "mob #{mob.short_name} attack cooldown reduced by weapon speed to #{mob.attack_cooldown}", "combat"
        end
      end
      @ticks_until_combat_round -= 1
      if @ticks_until_combat_round < 1
        @combat_round.next_round do |attacker, defender|
          orig = attacker.attack_cooldown
          melee_round attacker, defender
          @game.send_msg attacker, "{!{FM#{defender.condition}\n" if orig != attacker.attack_cooldown && @combat_round.valid_attack?(attacker)
        end
        @ticks_until_combat_round = COMBAT_ROUND
      end
      Log::info "end tick", "combat"
    end

    def aggress( attacker, defender )
      @combat_round.aggress attacker, defender
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

    def melee_round( attacker, defender )
      attack_speed = @weapon.attack_speed(attacker) # cache the same attack speed for entire round to prevent changes mid-around
      Log::debug "attacker #{attacker.short_name} started melee_round with #{attacker.attack_cooldown} cooldown, attack speed #{attack_speed}", "combat"
      if attacker.attack_cooldown < attack_speed then
        while attacker.attack_cooldown < attack_speed do
          Log::debug "attacker #{attacker.short_name} had enough cooldown (#{attacker.attack_cooldown}) for another melee attack", "combat"
          attacker.attack_cooldown += 1.0
          @weapon.melee_attack attacker, defender
          if @combat_round.target_of(attacker) != defender
            Log::debug "attacker #{attacker.short_name} loses the rest of his combat round because his target switched from #{defender.short_name} to #{@combat_round.target_of attacker}", "combat"
            break
          end
          break unless @combat_round.valid_attack? attacker
        end
      else
        Log::debug "attacker #{attacker.short_name} had insufficient cooldown (#{attacker.attack_cooldown}) to attack", "combat"
        @game.send_msg attacker, "{@Your attack speed hasn't recovered from your latest melee!\n"
      end
      Log::debug "attacker #{attacker.short_name} finished the melee round with cooldown #{attacker.attack_cooldown}", "combat"
    end
  end # end Public

  def self.damage_color( amount )
    color = ""
    DAMAGE_COLOR_TIER.each_pair do |min_amount,col|
      color = col if amount > min_amount
    end
    color
  end
  
  def self.damage_text( amount )
    label = ""
    DAMAGE_TIER.each_pair do |damage,min_amount|
      label = DAMAGE_TEXT[damage] if amount > min_amount
    end
    label
  end

  def self.damage_percent_text( percent )
    label = nil
    DAMAGE_PERCENT_TEXT.each_pair do |min_amount,text|
      label = text if percent > min_amount
    end
    label
  end
  
  def self.damage( game, damager, receiver, amount )
    raise "expected receiver to be a Mob" unless receiver.kind_of? Mob
    raise "expected amount to be an Integer" unless amount.kind_of? Fixnum
    if receiver.state == PhysicalState::Dead
      pov_scope do
        pov(receiver) { "{@You are already a corpse!\n" }
        pov(receiver.room.mobs) { "{@#{receiver.short_name} is already a corpse.\n" }
      end
      Log::debug "abandoning damage from #{damager.to_s} because #{receiver.short_name} is already a corpse", "combat"
      return
    end
    damage_object = { damager:damager, receiver:receiver, amount:amount }
    game.signal.fire :damage, damage_object
    damager = damage_object[:damager]
    receiver = damage_object[:receiver]
    amount = damage_object[:amount]
    if amount > 0 and receiver.state == PhysicalState::Resting
      pov_scope do
        pov(receiver) { "{!{FRYou take increased damage while resting!\n" }
        pov(receiver.room.mobs) { "{!{FR#{receiver.short_name} takes increased damage while resting!\n"}
      end
    elsif amount > 0 and receiver.state == PhysicalState::Meditating
      pov_scope do
        pov(receiver) { "{!{FRYou take {@{FR*massively*{! increased damage while meditating!\n" }
        pov(receiver.room.mobs) { "{!{FR#{receiver.short_name} takes {@{FR*massively*{! increased damage while meditating!\n"}
      end
    end
    if amount > receiver.hp_max / 3
      pov_scope do
        pov(receiver) { "{!{FRYou reel in shock from sudden blood loss!\n" }
      end
    end
    game.combat.aggress damager, receiver if damager and damager.kind_of? Mob
    receiver.hp -= amount
    receiver.hp = receiver.hp_max if receiver.hp > receiver.hp_max
    death game, receiver if receiver.hp < 1
  end

  def self.flee( game, attacker )
    raise "expected attacker to be a Mob" unless attacker.kind_of? Mob
    raise "expected attacker to have a room" unless attacker.room
    pov_scope do
      pov_none(attacker)
      pov(attacker.room.mobs) { "{!{FR#{attacker.short_name} becomes panic-stricken and attemps to flee.\n" }
    end
    if Random.new.rand(0..2) > 0 and attacker.room.exit.size > 0
      game.combat.disengage attacker if game.combat.engaged? attacker
      exit = attacker.room.exit.each_value.to_a.sample
      game.exit_room attacker, exit, "flies"
      game.send_msg attacker, "{!{FRYou flee in a near-blind panic.\n"
    else
      game.send_msg attacker, "{!{FRIn your panic-stricken state, you fail to get away!\n"
    end
  end

  def self.glance( game, mob, target )
    raise "expected mob to be a Mob" unless mob.kind_of? Mob
    if target.empty?
      CoreCommands::look game, mob
      return
    end
    mob.room.mobs.each do |mob_in_room|
      if mob_in_room.short_name =~ Regexp.new( "^#{target}", Regexp::IGNORECASE)
        pov_scope do
          pov(mob) { "{!{FY#{mob_in_room.condition}\n" }
          pov(mob_in_room) { "{!{FY#{mob.short_name} glances at you.\n" }
          pov(mob.room.mobs) { "{!{FY#{mob.short_name} glances at #{mob_in_room.short_name}.\n" }
        end
        return
      end
    end
    game.send_msg mob, "You do not see that here.\n"
  end

  KILL_LAG = COMBAT_ROUND
  def self.kill( game, attacker, target )
    raise "expected attacker to be a Mob" unless attacker.kind_of? Mob
    raise "expected target to be a String" unless target.kind_of? String
    if target.empty?
      game.send_msg attacker, "Yes! Sate your bloodlust!! But on who?\n"
      return
    end
    game.add_lag attacker, KILL_LAG
    attacker.room.mobs.each do |mob_in_room|
      if mob_in_room.short_name =~ Regexp.new( "^#{target}", Regexp::IGNORECASE) and attacker != mob_in_room
        if mob_in_room.dead?
          game.send_msg attacker, "#{mob_in_room.short_name} is already dead.\n"
          return
        end
        game.combat.melee_round attacker, mob_in_room
        return
      end
    end
    game.send_msg attacker, "They aren't here.\n"
  end

  def self.pit_duel( game, attacker, target )
    raise "expected attacker to be a Mob" unless attacker.kind_of? Mob
    raise "expected target to be a String" unless target.kind_of? String
    if target.empty?
      game.send_msg attacker, "Yes! Sate your bloodlust!! But on who?\n"
      return
    end
    attacker.room.mobs.each do |mob_in_room|
      if mob_in_room.short_name =~ Regexp.new( "^#{target}", Regexp::IGNORECASE) and attacker != mob_in_room
        if mob_in_room.dead?
          game.send_msg attacker, "#{mob_in_room.short_name} is already dead.\n"
          return
        end
        duel = PitDuel.new game, attacker, mob_in_room
        duel.start
        return
      end
    end
    game.send_msg attacker, "They aren't here.\n"
  end
  
  def self.green_beam( game, mob )
    game.add_lag mob, KILL_LAG
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
    damage( game, mob, dies, dies.hp )
  end

  def self.restore( mob )
    pov_scope do
      pov(mob) { "{!{FCYou shriek in pain as all of your wounds are suddenly healed.\n" }
      pov(mob.room.mobs) { "{!{FY#{mob.short_name} shrieks in pain as all of his wounds are suddenly healed.\n" }
    end
    mob.hp = mob.hp_max
    mob.energy = mob.energy_max
  end

  def self.death( game, mob )
    Log::info "#{mob.short_name} died", "combat"
    PhysicalState::transition game, mob, PhysicalState::Dead
  end
end


