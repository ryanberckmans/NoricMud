module Game
  @rooms = Room.find :all
  @rooms.each do |room|
    room.mobs = []
  end
  @characters = []

  def self.tick
    Log::debug "start tick", "game"
    process_new_disconnections
    process_new_connections
    process_character_commands
    Log::debug "end tick", "game"
  end

  private
  def self.character_connected( char )
    index = @characters.index char
    if index
      # i.e. char already in @characters, already logged on, use cached copy, because it has the transient attributes
      char = @characters[index]
    end
    
    verify_mob_has_no_character char
    char.mob.char = char

    if char.mob.room
      # i.e. char.mob is in physical world, reconnect
      Log::info "#{char.name} reconnected", "game"
      Helper::send_to_room char.mob.room, "#{char.name} reconnected.\n"
    else
      # i.e. char.mob has no room, logon
      Log::info "#{char.name} logging on", "game"
      @characters << char
      Commands::poof char.mob, @rooms[0]
    end
    Commands::look char.mob
  end

  def self.is_reconnect?( char )
    @characters.index char
  end

  def self.character_disconnected( char )
    verify_mob_has_character char
    Log::info "#{char.name} disconnected (lost link)", "game"
    char.mob.char = nil
    Helper::send_to_room char.mob.room, "#{char.name} disconnected.\n"
  end

  def self.log_off_character( char )
    Helper::move_to( char.mob, nil )
    @characters.delete char
    CharacterLoginSystem::disconnect char
  end

  def self.verify_mob_has_character( char )
    raise "expected #{char.name}.mob to have a character connected to it" unless char.mob.char
  end

  def self.verify_mob_has_no_character( char )
    raise "expected #{char.name}.mob to have no character connected to it" if char.mob.char
  end

  def self.process_new_connections
    CharacterLoginSystem::new_connections.each do |char| character_connected char end
  end

  def self.process_new_disconnections
    CharacterLoginSystem::new_disconnections.each do |char| character_disconnected char end
  end

  def self.process_character_commands
    @characters.each do |char|
      next unless char.mob.char
      cmd = CharacterLoginSystem::next_command char
      next unless cmd
      Commands::look char.mob if cmd == "look"
      Commands::poof char.mob, @rooms[0] if cmd == "poof"
      Commands::say char.mob, $' if cmd =~ /\Asay /
      if cmd =~ /quit/
        Log::info "#{char.name} quit", "game"
        Helper::send_to_room char.mob.room, "#{char.name} quit.\n"
        log_off_character char
      end
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

    def self.send_to_room( room, msg )
      room.mobs.each do |mob|
        if mob.char
          CharacterLoginSystem::send_msg mob.char, msg
          Log::debug "send_to_room, room #{room.name}, mob #{mob.short_name} received the message", "game"
        end
      end
      Log::debug "send_to_room, room #{room.name} contained #{room.mobs.size} mobs", "game"
    end
  end

  module Commands
    def self.poof( mob, room )
      Helper::send_to_room room, "{!{FWPFFT. #{mob.short_name} disappears in a puff of white smoke.\n" if mob.room
      Helper::move_to mob, room
      Helper::send_to_room room, "{!{FWBANG! #{mob.short_name} appears in a burst of white smoke.\n" if mob.room
      Log::debug "mob #{mob.short_name} poofed to #{room.name}"
    end

    def self.look( mob )
      return unless mob.room and mob.char
      look = "{!"
      look += "{FY#{mob.room.name}\n"
      look += "{FM#{mob.room.description}\n"
      mob.room.mobs.each do |mob_in_room|
        next if mob_in_room == mob
        look += "{FG#{mob_in_room.long_name} is here."
        look += " {@{FW[LOST LINK]" if not mob_in_room.char
        look += "\n"
      end
      CharacterLoginSystem::send_msg mob.char, look
    end

    def self.say( mob, msg )
      Log::debug "mob #{mob.short_name} says #{msg}", "game"
      return unless mob.room and msg
      msg.lstrip!
      return unless msg.length > 0
      Helper::send_to_room mob.room, "{!{FC#{mob.short_name} says, '#{msg}'\n"
    end
  end
end
