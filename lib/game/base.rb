
module Game
  @rooms = Room.find :all
  @rooms.each do |room|
    room.exits.each do |exit|
      exit.destination = @rooms[@rooms.index exit.destination]
    end
  end

  $character_system = nil
  @msgs_this_tick = {}
  @new_logouts = []

  pov_send ->(c,m){ Game::send_msg c, m }

  def self.set_character_system( cs )
    $character_system = cs
  end

  def self.send_msg( entity, msg )
    char = nil
    if entity.kind_of? Mob
      char = entity.char
    elsif entity.kind_of? Character
      char = entity
    end
    return unless char and $character_system.connected? char
    @msgs_this_tick[char] ||= "\n"
    @msgs_this_tick[char] += msg
  end

  def self.tick
    @msgs_this_tick.clear
    Log::debug "start tick", "game"
    process_new_disconnections
    process_new_reconnections
    process_new_logins
    process_character_commands
    send_char_msgs
    while char = @new_logouts.shift do
      $character_system.logout char
    end
    send_prompts
    Log::debug "end tick", "game"
  end

  private
  def self.send_char_msgs
    @msgs_this_tick.each_pair do |char,msg|
      $character_system.send_msg char, msg
    end
  end

  def self.prompt( char )
    "\n{@{!{FU<#{char.mob.hp_color}{FUhp #{char.mob.energy_color}{FUe> "
  end
  
  def self.send_prompts
    @msgs_this_tick.each_key do |char|
      $character_system.send_msg char, prompt(char) if $character_system.online? char
    end
  end
  
  def self.login( char )
    verify_mob_has_no_character char
    char.mob.char = char
    Log::info "#{char.name} logging on", "game"
    Commands::poof char.mob, @rooms[0]
    Commands::look char.mob
    Game::send_msg char, COMMANDS
  end

  COMMANDS = "{!{FY--> {@Current commands are {!{FCn e s w u d{@, {!{FCenergy{@, {!{FChp{@, {!{FClook{@, {!{FCsay{@, {!{FCexits{@, {!{FCquit{@. Try losing link, reconnecting, multiplaying, creating multiple chars, breaking it, etc.\n"
  def self.character_reconnected( char )
    raise "expected char to be connected" unless $character_system.connected? char
    Log::info "#{char.name} reconnected", "game"
    pov_scope do
      pov(char.mob) do "Reconnected.\n" end
      pov(char.mob.room.mobs) do "#{char.name} reconnected.\n" end
    end
    Commands::look char.mob
    Game::send_msg char, COMMANDS
  end

  def self.character_disconnected( char )
    raise "expected char to be online" unless $character_system.online? char
    verify_mob_has_character char
    Log::info "#{char.name} disconnected (lost link)", "game"
    pov_scope do
      pov_none(char.mob)
      pov(char.mob.room.mobs) do "#{char.name} disconnected.\n" end
    end
  end

  def self.logout( char )
    raise "expected char to be online" unless $character_system.online? char
    Log::info "#{char.name} logging off", "game"
    pov_scope do
      pov(char.mob) do "Quitting...\n" end
      pov(char.mob.room.mobs) do "#{char.name} quit.\n" end
    end
    Helper::move_to( char.mob, nil )
    @new_logouts << char
  end

  def self.verify_mob_has_character( char )
    raise "expected #{char.name}.mob to have a character connected to it" unless char.mob.char
  end

  def self.verify_mob_has_no_character( char )
    raise "expected #{char.name}.mob to have no character connected to it" if char.mob.char
  end

  def self.process_new_reconnections
    while char = $character_system.next_character_reconnection do
      character_reconnected char
    end
  end

  def self.process_new_disconnections
    while char = $character_system.next_character_disconnection do
      character_disconnected char
    end
  end

  def self.process_new_logins
    while char = $character_system.next_character_login do
      login char
    end
  end

  def self.process_character_commands
    $character_system.each_connected_char do |char|
      cmd = $character_system.next_command char
      next unless cmd
      @msgs_this_tick[char] ||= ""
      func = Commands::find cmd
      next unless func
      func[:value][char, func[:rest], func[:match]]
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

    def self.exit_room( mob, exit, dir )
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
        Game::Commands::look( mob )
      else
        Game::send_msg mob, "{@Alas, you cannot go that way...\n"
      end
    end
  end

  module Commands
    @parser = AbbrevMap.new
    @parser.add "north", ->(char,rest, match) { Helper::exit_room(char.mob,char.mob.room.north,"north") }
    @parser.add "south", ->(char,rest, match) { Helper::exit_room(char.mob,char.mob.room.south,"south") }
    @parser.add "up", ->(char,rest, match) { Helper::exit_room(char.mob,char.mob.room.up,"up") }
    @parser.add "down", ->(char,rest, match) { Helper::exit_room(char.mob,char.mob.room.down,"down") }
    @parser.add "west", ->(char,rest, match) { Helper::exit_room(char.mob,char.mob.room.west,"west") }
    @parser.add "east", ->(char,rest, match) { Helper::exit_room(char.mob,char.mob.room.east,"east") }
    @parser.add "say", ->(char,rest, match) { say(char.mob,rest) }
    @parser.add "look", ->(char,rest, match) { look( char.mob ) }
    @parser.add "exits", ->(char,rest, match) { exits( char.mob ) }
    @parser.add "quit", ->(char,rest, match) { quit( char ) if match == "quit" }
    @parser.add "hp", ->(char,rest,match) { char.mob.hp -= 25; char.mob.hp = 1 if char.mob.hp < 1 }
    @parser.add "energy", ->(char,rest,match) { char.mob.energy -= 10; char.mob.energy = 1 if char.mob.energy < 1 } 

    def self.find( cmd )
      @parser.find cmd
    end

    def self.quit( char )
      Log::info "#{char.name} quit", "game"

      Game::logout char
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

    def self.exits( mob )
      return unless mob.room
      room = mob.room
      exits = "{!{FUObvious exits:\n"
      exits += "North  - " + room.north.destination.name + "\n" if room.north
      exits += "East   - " + room.east.destination.name + "\n"  if room.east
      exits += "South  - " + room.south.destination.name + "\n"  if room.south
      exits += "West   - " + room.west.destination.name + "\n"  if room.west
      exits += "Up     - " + room.up.destination.name + "\n"  if room.up
      exits += "Down   - " + room.down.destination.name + "\n"  if room.down
      Game::send_msg mob, exits
    end

    def self.look( mob )
      return unless mob.room and mob.char
      look = "{!"
      look += "{FY#{mob.room.name}\n"
      look += "{FM#{mob.room.description}\n" unless not mob.room.description or mob.room.description.empty?
      mob.room.mobs.each do |mob_in_room|
        next if mob_in_room == mob
        look += "{!{FG#{mob_in_room.long_name} is here."
        look += " {@{FW[Lost Link]" if not $character_system.connected? mob_in_room.char
        look += "\n"
      end
      Game::send_msg mob, look
      exits( mob )
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
