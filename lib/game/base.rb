require "core_commands/base.rb"
require "combat/base.rb"
require "pit_duel.rb"
require "breath.rb"
require "lag.rb"
require "cooldown.rb"
require "channel.rb"
require "regen.rb"
require "abilities/base.rb"
require "chaos_quest.rb"

class Game

  attr_reader :signal, :timer
  
  def initialize( character_system )
    raise "expected a CharacterSystem" unless character_system.kind_of? CharacterSystem
    @character_system = character_system

    @signal = Driver::Signal.new
    @timer = Timer.new @signal
    @breath = Breath.new self
    @channel = Channel.new self
    @cooldown = Cooldown.new
    @lag = Lag.new
    @regen = Regen.new self
    
    @rooms = Room.find :all

    @login_room = @rooms.each do |room|
      break room if room.name == "A Bloody Combat Pit"
    end
    raise "expected login_room to be a Room" unless @login_room.kind_of? Room
    @respawn_room = @rooms.each do |room|
      break room if room.name == "Within Illuminated Mists"
    end
    raise "expected respawn_room to be a Room" unless @respawn_room.kind_of? Room

    @mob_commands = MobCommands.new self

    @core_commands = CoreCommands.new self
    @combat = Combat.new self

    @msgs_this_tick = {}
    @new_logouts = []

    @secret_cmds = AbbrevMap.new
    @secret_cmds.add "east", ->(game,mob,rest,match) do
      raise AbandonCallback.new if mob.room.name != "A Bloody Combat Pit" or game.combat.engaged? mob
      
      if (Random.new.rand(1..4) > 1) then
        pov_scope {
          pov(mob) { "You fail to focus your concentration and the {!{FMP{FYs{FGy{FCch{FGe{FYd{FMe{FYl{FGi{FCc {@portal remains {!{FRclosed{@.\n" }
          pov(mob.room.mobs) { "#{mob.short_name} takes a run at it, but the {!{FMP{FYs{FGy{FCch{FGe{FYd{FMe{FYl{FGi{FCc {@portal remains {!{FRclosed{@.\n" }
        }
        return
      end
      
      pov_scope do
        pov(mob) { "You crash into the {!{FMP{FYs{FGy{FCch{FGe{FYd{FMe{FYl{FGi{FCc {@portal and tear it {!{FGopen{@. You fall through the light and find yourself elsewhere.\n" }
        pov(mob.room.mobs) { "#{mob.short_name} crashes through the {!{FMP{FYs{FGy{FCch{FGe{FYd{FMe{FYl{FGi{FCc {@portal, tearing it {!{FGopen{@. The portal flares rainbow and weaves itself shut.\n" }
      end
      move_to mob, Room.find(:all).sample
      pov_scope do
        pov_none(mob)
        pov(mob.room.mobs) { "#{mob.short_name} appears in a blinding flash of {!{FMP{FYs{FGy{FCch{FGe{FYd{FMe{FYl{FGi{FCc {@light.\n" }
      end
      CoreCommands.look self, mob
    end
    @secret_cmds.add "heal", ->(game,mob,rest,match) { if mob.room.name =~ /Subterranean Forest/ then send_msg mob.char, "A bright {!{FGsubterranean forest aura{@ heals your wounds.\n"; mob.hp = mob.hp_max; mob.energy = mob.energy_max else raise AbandonCallback.new end }

    pov_send ->(c,m){ send_msg c, m }
    @chaos_quest = ChaosQuest.new self
  end

  def respawn_room
    @respawn_room
  end

  def login_room
    @login_room
  end

  def mob_commands
    @mob_commands
  end

  def combat
    @combat
  end

  def all_connected_characters
    chars = []
    @character_system.each_connected_char do |char| chars << char end
    chars
  end

  def all_characters
    chars = []
    @character_system.each_char do |char| chars << char end
    chars
  end

  def connected?( char )
    @character_system.connected? char
  end

  def send_msg( entity, msg )
    char = nil
    if entity.kind_of? Mob
      char = entity.char
    elsif entity.kind_of? Character
      char = entity
    end
    return unless char and @character_system.connected? char
    @msgs_this_tick[char] ||= "\n"
    @msgs_this_tick[char] += msg + "{@"
  end

  def tick
    @msgs_this_tick.clear
    Log::debug "start tick", "game"
    @signal.fire :before_tick
    process_new_disconnections
    process_new_reconnections
    process_new_logins
    @breath.tick
    @lag.tick
    @cooldown.tick
    @regen.tick
    process_character_commands
    @channel.tick
    @combat.tick
    @signal.fire :after_tick
    while char = @new_logouts.shift do do_logout char end
    send_char_msgs
    send_prompts
    Log::debug "end tick", "game"
  end

  def logout( char )
    raise "expected char to be a Character" unless char.kind_of? Character
    raise "expected char to be online" unless @character_system.online? char
    @new_logouts << char
  end

  def move_to( mob, room )
    combat.disengage mob if combat.engaged? mob
    previous_room = mob.room
    mob.room.mobs.delete mob if mob.room
    mob.room = room
    Log::debug "moved #{mob.short_name} to room #{room ? room.name : "nil"}, previous room #{previous_room ? previous_room.name : "nil"}", "game"
    room.mobs << mob if room
  end

  def exit_room( mob, exit, verb="leaves" )
    raise "expected mob to be a Mob" unless mob.kind_of? Mob
    if exit
      raise "expected exit to be an Exit" unless exit.kind_of? Exit
      return unless @breath.try_move mob
      pov_scope do
        pov_none(mob)
        pov(mob.room.mobs) do "{!{FW#{mob.short_name} #{verb} #{Exit.i_to_s exit.direction}.\n" end
      end
      move_to( mob, exit.destination )
      pov_scope do
        pov_none(mob)
        pov(mob.room.mobs) do "{!{FW#{mob.short_name} has arrived.\n" end
      end
      CoreCommands::look( self, mob )
    else
      send_msg mob, "{@Alas, you cannot go that way...\n"
    end
  end

  def add_lag( mob, lag )
    @lag.add_lag mob, lag
    PhysicalState::transition self, mob, PhysicalState::Standing if mob.state == PhysicalState::Channeling
    nil
  end

  def lag_recovery_action( mob, action )
    @lag.recovery_action mob, action
  end

  def add_cooldown( mob, ability, cooldown, recovery_action=nil )
    @cooldown.add_cooldown mob, ability, cooldown, recovery_action
  end

  def in_cooldown?( mob, ability )
    @cooldown.in_cooldown? mob, ability
  end

  def cooldowns( mob )
    @cooldown.cooldowns mob
  end

  def cancel_channel( mob )
    @channel.cancel_channel mob
  end

  def channel( mob, ability, channel_duration )
    @channel.channel mob, ability, channel_duration
  end

  def channeling?( mob )
    @channel.channeling? mob
  end

  def chaos_enroll( mob )
    @chaos_quest.enroll mob
  end

  private
  def do_logout( char )
    raise "expected char to be online" unless @character_system.online? char
    Log::info "#{char.name} logging off", "game"
    signal.fire :logout, char
    mob = char.mob
    pov_scope do
      pov(mob) do "{@Quitting...\n" end
      pov(mob.room.mobs) do "{@#{mob.char.name} quit.\n" end
    end
    move_to( mob, nil )
    @character_system.send_msg char, @msgs_this_tick[char]
    @msgs_this_tick.delete char
    @mob_commands.remove mob
    @cooldown.delete mob
    @character_system.logout char
  end

  def send_char_msgs
    @msgs_this_tick.each_pair do |char,msg|
      @character_system.send_msg char, msg
    end
  end

  def prompt( char )
    "\n{@{!{FU<#{char.mob.hp_color}{FUhp #{char.mob.energy_color}{FUe #{@breath.breath_color char.mob}{FUbr> "
  end
  
  def send_prompts
    @msgs_this_tick.each_key do |char|
      @character_system.send_msg char, prompt(char)
    end
  end
  
  def login( char )
    char.mob.char = char
    @mob_commands.add char.mob
    @mob_commands.add_cmd_handler char.mob, @secret_cmds, 10
    Log::info "#{char.name} logging on", "game"
    CoreCommands::poof self, char.mob, @login_room
    PhysicalState::transition( self, char.mob, PhysicalState::Standing ) unless char.mob.state
    @chaos_quest.enroll char.mob
  end

  def character_reconnected( char )
    raise "expected char to be connected" unless @character_system.connected? char
    Log::info "#{char.name} reconnected", "game"
    pov_scope do
      pov(char.mob) do "Reconnected.\n" end
      pov(char.mob.room.mobs) do "#{char.name} reconnected.\n" end
    end
    CoreCommands::look self, char.mob
  end

  def character_disconnected( char )
    raise "expected char to be online" unless @character_system.online? char
    verify_mob_has_character char
    Log::info "#{char.name} disconnected (lost link)", "game"
    pov_scope do
      pov_none(char.mob)
      pov(char.mob.room.mobs) do "#{char.name} disconnected.\n" end
    end
  end

  def verify_mob_has_character( char )
    raise "expected #{char.name}.mob to have a character connected to it" unless char.mob.char
  end

  def verify_mob_has_no_character( char )
    raise "expected #{char.name}.mob to have no character connected to it" if char.mob.char
  end

  def process_new_reconnections
    while char = @character_system.next_character_reconnection do
      character_reconnected char
    end
  end

  def process_new_disconnections
    while char = @character_system.next_character_disconnection do
      character_disconnected char
    end
  end

  def process_new_logins
    while char = @character_system.next_character_login do
      login char
    end
  end

  def process_character_commands
    @character_system.each_connected_char do |char|
      if @lag.lagged? char.mob
        Log::debug "#{char.name} was lagged and didn't get a cmd this tick", "game"
        next
      end
      if @channel.channeling? char.mob
        Log::debug "#{char.name} was channeling and didn't get a cmd this tick", "game"
        next
      end
      cmd = @character_system.next_command char
      next unless cmd
      @msgs_this_tick[char] ||= ""
      next if cmd.empty?
      send_msg char, "Thou must be no such command.\n" unless @mob_commands.handle_cmd( char.mob, cmd )
    end
  end
end
