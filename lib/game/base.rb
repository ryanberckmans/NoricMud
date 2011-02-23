module Game
  @rooms = Room.find :all
  @rooms.each do |room|
    room.mobs = []
  end
  @characters = []

  def self.tick
    Log::debug "start tick", "game"
    Login::new_logins.each do |char| logon char end
    process_character_commands
    Log::debug "end tick", "game"
  end

  private
  def self.logon( char )
    Log::info "logging on #{char.name}", "game"
    @characters << char
    Commands::poof char.mob, @rooms[0]
    Commands::look char.mob
  end

  def self.process_character_commands
    @characters.each do |char|
      cmd = Network::next_command char.socket
      next unless cmd
      Commands::look char.mob if cmd == "look"
      Commands::poof char.mob, @rooms[0] if cmd == "poof"
      Commands::say char.mob, $' if cmd =~ /\Asay /
    end
  end

  module Helper
    def self.move_to( mob, room )
      previous_room = mob.room
      mob.room.mobs.delete mob if mob.room
      mob.room = room
      room.mobs << mob
      Log::debug "moved #{mob.short_name} to room #{room.name}, previous room #{previous_room ? previous_room.name : "nil"}", "game"
    end

    def self.send_to_room( room, msg )
      room.mobs.each do |mob|
        if mob.char
          Network::send mob.char.socket, msg
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
      Network::send mob.char.socket, look
    end

    def self.say( mob, msg )
      Log::debug "mob #{mob.short_name} says #{msg}", "game"
      return unless mob.room and msg
      msg.lstrip!
      return unless msg.length > 0
      Helper::send_to_room mob.room, "{!{FC#{mob.short_name} says, '#{msg}'\n"
    end

    def self.quit( mob )
      
    end
  end
end
