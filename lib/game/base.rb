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
    verify_mob_has_no_character char
    char.mob.char = char

    if character_logged_on? char
      verify_character_disconnected char
      Log::info "#{char.name} reconnected", "game"
      cached = @characters[@characters.index char]
      Log::info "#{char.name} reconnected instance has: #{char.object_id} #{char.mob.room.to_s}, cached instance #{cached.object_id} #{cached.mob.room.to_s}"
      Helper::send_to_room char.mob.room, "#{char.name} reconnected.\n"
    else
      Log::info "#{char.name} logging on", "game"
      @characters << char
      Commands::poof char.mob, @rooms[0]
    end
    char.connected = true
    Commands::look char.mob
  end

  def self.character_logged_on?( char )
    @characters.index char
  end

  def self.character_disconnected( char )
    verify_character_connected char
    Log::info "#{char.name} disconnected (lost link)", "game"
    char.connected = false
    char.mob.char = nil
    Helper::send_to_room char.mob.room, "#{char.name} disconnected.\n"
  end

  def self.log_off_character( char )
    Helper::move_to( char.mob, nil )
    @characters.delete char
    CharacterLoginSystem::disconnect char
  end

  def self.verify_mob_has_no_character( char )
    raise "expected #{char.name}.mob to have no character connected to it" if char.mob.char
  end

  def self.verify_character_connected( char )
    raise "expected #{char.name} to be connected" unless char.connected
  end

  def self.verify_character_disconnected( char )
    raise "expected #{char.name} to be disconnected" if char.connected
  end

  def self.process_new_connections
    CharacterLoginSystem::new_connections.each do |char| character_connected char end
  end

  def self.process_new_disconnections
    CharacterLoginSystem::new_disconnections.each do |char| character_disconnected char end
  end

  def self.process_character_commands
    @characters.each do |char|
      next unless char.connected
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
          CharacterLoginSystem::send mob.char, msg
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
        look += "{FG#{mob_in_room.long_name} is here.\n" unless mob_in_room == mob
      end
      CharacterLoginSystem::send mob.char, look
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
