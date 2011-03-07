
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

    @mob_commands = MobCommands.new self

    @msgs_this_tick = {}
    @new_logouts = []

    pov_send ->(c,m){ send_msg c, m }
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
    @msgs_this_tick[char] += msg
  end

  def tick
    @msgs_this_tick.clear
    Log::debug "start tick", "game"
    process_new_disconnections
    process_new_reconnections
    process_new_logins
    process_character_commands
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
    pov_scope do
      pov(char.mob) do "Quitting...\n" end
      pov(char.mob.room.mobs) do "#{char.name} quit.\n" end
    end
    Helper::move_to( char.mob, nil )
    @new_logouts << char
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
    @mob_commands.add_cmd_handler char.mob, Commands::map, 0
    Log::info "#{char.name} logging on", "game"
    Commands::poof char.mob, @rooms[0]
    Commands::look self, char.mob
    send_msg char, COMMANDS
  end

  COMMANDS = "{!{FY--> {@Current commands are {!{FCn e s w u d{@, {!{FCenergy{@, {!{FChp{@, {!{FClook{@, {!{FCsay{@, {!{FCexits{@, {!{FCquit{@. Try losing link, reconnecting, multiplaying, creating multiple chars, breaking it, etc.\n"
  def character_reconnected( char )
    raise "expected char to be connected" unless @character_system.connected? char
    Log::info "#{char.name} reconnected", "game"
    pov_scope do
      pov(char.mob) do "Reconnected.\n" end
      pov(char.mob.room.mobs) do "#{char.name} reconnected.\n" end
    end
    Commands::look char.mob
    send_msg char, COMMANDS
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
      @mob_commands.handle_cmd char.mob, cmd
    end
  end

  module Helper
    def self.move_to( mob, room )
      previous_room = mob.room
      mob.room.mobs.delete mob if mob.room
      mob.room = room
      Log::debug "moved #{mob.short_name} to room #{room ? room.name : "nil"}, previous room #{previous_room ? previous_room.name : "nil"}", "game"
      room.mobs << mob if room
    end

    def self.exit_room( game, mob, exit, dir )
      if exit
        pov_scope do
          pov_none(mob)
          pov(mob.room.mobs) do "{!{FW#{mob.short_name} leaves #{dir}.\n" end
        end
        move_to( mob, exit.destination )
        pov_scope do
          pov_none(mob)
          pov(mob.room.mobs) do "{!{FW#{mob.short_name} has arrived.\n" end
        end
        Game::Commands::look( game, mob )
      else
        game.send_msg mob, "{@Alas, you cannot go that way...\n"
      end
    end
  end

  module Commands
    @cmd_map = AbbrevMap.new
    @cmd_map.add "north", ->(game, mob, rest, match) { Helper::exit_room(game, mob,mob.room.north,"north") }
    @cmd_map.add "south", ->(game, mob, rest, match) { Helper::exit_room(game, mob,mob.room.south,"south") }
    @cmd_map.add "up", ->(game, mob, rest, match) { Helper::exit_room(game, mob,mob.room.up,"up") }
    @cmd_map.add "down", ->(game, mob, rest, match) { Helper::exit_room(game, mob,mob.room.down,"down") }
    @cmd_map.add "west", ->(game, mob, rest, match) { Helper::exit_room(game, mob,mob.room.west,"west") }
    @cmd_map.add "east", ->(game, mob, rest, match) { Helper::exit_room(game, mob,mob.room.east,"east") }
    @cmd_map.add "say", ->(game, mob, rest, match) { say(mob, rest) }
    @cmd_map.add "look", ->(game, mob, rest, match) { look( game, mob ) }
    @cmd_map.add "exits", ->(game, mob, rest, match) { exits( game, mob ) }
    @cmd_map.add "quit", ->(game, mob, rest, match) { quit( game, mob.char ) if match == "quit" }
    @cmd_map.add "hp", ->(game, mob, rest, match) { mob.hp -= 25; mob.hp = 1 if mob.hp < 1 }
    @cmd_map.add "energy", ->(game, mob, rest, match) { mob.energy -= 10; mob.energy = 1 if mob.energy < 1 }

    def self.map
      @cmd_map
    end
    
    def self.quit( game, char )
      Log::info "#{char.name} quit", "game"
      game.logout char
    end
    
    def self.poof_out( mob )
      pov_scope do
        pov(mob) do
          "{!{FWPFFT. You disappear in a puff of white smoke.\n"
        end
        pov(mob.room.mobs) do
          "{!{FWPFFT. #{mob.short_name} disappears in a puff of white smoke.\n"
        end
      end
    end

    def self.poof_in( mob )
      pov_scope do
        pov(mob) do
          "{!{FWBANG! You appear in a burst of white smoke.\n"
        end
        pov(mob.room.mobs) do
          "{!{FWBANG! #{mob.short_name} appears in a burst of white smoke.\n"
        end
      end
    end
    
    def self.poof( mob, room )
      poof_out mob if mob.room
      Helper::move_to mob, room
      poof_in mob if mob.room
      Log::debug "mob #{mob.short_name} poofed to #{room.name}"
    end

    def self.exits( game, mob )
      return unless mob.room
      room = mob.room
      exits = "{!{FUObvious exits:\n"
      exits += "North  - " + room.north.destination.name + "\n" if room.north
      exits += "East   - " + room.east.destination.name + "\n"  if room.east
      exits += "South  - " + room.south.destination.name + "\n"  if room.south
      exits += "West   - " + room.west.destination.name + "\n"  if room.west
      exits += "Up     - " + room.up.destination.name + "\n"  if room.up
      exits += "Down   - " + room.down.destination.name + "\n"  if room.down
      game.send_msg mob, exits
    end

    def self.look( game, mob )
      return unless mob.room and mob.char
      look = "{!"
      look += "{FY#{mob.room.name}\n"
      look += "{FM#{mob.room.description}\n" unless not mob.room.description or mob.room.description.empty?
      mob.room.mobs.each do |mob_in_room|
        next if mob_in_room == mob
        look += "{!{FG#{mob_in_room.long_name} is here."
        look += " {@{FW[Lost Link]" if not game.connected? mob_in_room.char
        look += "\n"
      end
      game.send_msg mob, look
      exits( game, mob )
    end

    def self.say( mob, msg )
      Log::debug "mob #{mob.short_name} says #{msg}", "game"
      msg.lstrip!
      return unless msg.length > 0
      pov_scope do
        pov(mob) do
          "{!{FCYou say, '#{msg}'\n"
        end
        pov(mob.room.mobs) do
          "{!{FC#{mob.short_name} says, '#{msg}'\n"
        end
      end
    end
  end
end
