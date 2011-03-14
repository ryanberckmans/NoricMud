require "core_commands/base.rb"
require "combat/base.rb"

class Game
  
  def initialize( character_system )
    raise "expected a CharacterSystem" unless character_system.kind_of? CharacterSystem
    @character_system = character_system

    @rooms = Room.find :all
    @rooms.each do |room|
      room.exits.each do |exit|
        exit.destination = @rooms[@rooms.index exit.destination]
      end
    end

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
    @secret_cmds.add "east", ->(game,mob,rest,match) { if mob.room.name =~ /Pit/ then send_msg mob.char, "The {!{FMP{FYs{FGy{FCch{FGe{FYd{FMe{FYl{FGi{FCc {@portal is {!{FRclosed{@. {!{FMPurple monkey dishwasher{@.\n" else raise AbandonCallback.new end }
    @secret_cmds.add "heal", ->(game,mob,rest,match) { if mob.room.name =~ /Subterranean Forest/ then send_msg mob.char, "A bright {!{FGsubterranean forest aura{@ heals your wounds.\n"; mob.hp = mob.hp_max; mob.energy = mob.energy_max else raise AbandonCallback.new end }

    @rage = AbbrevMap.new
    @rage.add "rage", ->(game,mob,rest,match) { game.send_msg mob, "{!{FC***{@Secret {!{FRRAGE ACTIVATED{@ because your hp is low.{!{FC***\n" }
    @secret_cmds2 = ->(mob) { if mob.hp < 150 then @rage else nil end }
    
    pov_send ->(c,m){ send_msg c, m }
  end

  def respawn_room
    @respawn_room
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
    process_new_disconnections
    process_new_reconnections
    process_new_logins
    process_character_commands
    @combat.tick
    send_char_msgs
    while char = @new_logouts.shift do
      @mob_commands.remove char.mob
      @character_system.logout char
    end
    send_prompts
    Log::debug "end tick", "game"
  end

  def logout( char )
    raise "expected char to be online" unless @character_system.online? char
    Log::info "#{char.name} logging off", "game"
    move_to( char.mob, nil )
    @new_logouts << char
  end

  def move_to( mob, room )
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

  private
  def send_char_msgs
    @msgs_this_tick.each_pair do |char,msg|
      @character_system.send_msg char, msg
    end
  end

  def prompt( char )
    "\n{@{!{FU<#{char.mob.hp_color}{FUhp #{char.mob.energy_color}{FUe> "
  end
  
  def send_prompts
    @msgs_this_tick.each_key do |char|
      @character_system.send_msg char, prompt(char) if @character_system.online? char
    end
  end
  
  def login( char )
    verify_mob_has_no_character char
    char.mob.char = char
    @mob_commands.add char.mob
    @mob_commands.add_cmd_handler char.mob, @secret_cmds, 10
    @mob_commands.add_cmd_handler char.mob, @secret_cmds2, 20
    Log::info "#{char.name} logging on", "game"
    CoreCommands::poof self, char.mob, @login_room
    CoreCommands::look self, char.mob
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
      cmd = @character_system.next_command char
      next unless cmd
      @msgs_this_tick[char] ||= ""
      next if cmd.empty?
      send_msg char, "Thou must be no such command.\n" unless @mob_commands.handle_cmd( char.mob, cmd )
    end
  end
end
