
module CoreCommands
  @default_names = {}
  @show_room_id = {}
  
  class << self

    def set_default_room_name( mob, name )
      @default_names[mob] = name
    end
    
    def get_default_room_name( mob )
      @default_names[mob] ||= "New Room"
      @default_names[mob]
    end

    def show_room_id?( mob )
      @show_room_id[mob]
    end

    def room_toggle_show_id( game, mob )
      raise "expected mob to be a Mob" unless mob.kind_of? Mob
      if @show_room_id.key? mob
        @show_room_id[mob] = !@show_room_id[mob]
      else
        @show_room_id[mob] = true
      end
      if show_room_id? mob
        game.send_msg mob, "Showing room ids.\n"
      else
        game.send_msg mob, "Not showing room ids.\n"
      end
    end

    def room_create( game, mob, rest )
      raise "expected mob to be a Mob" unless mob.kind_of? Mob
      raise "expected mob to have a Room" unless mob.room
      raise "expected rest to be a String" unless rest.kind_of? String
      
      usage = "room create DIRECTION\n\n"
      usage += "DIRECTION: north | east | south | west | up | down\n\n"
      usage += "creates a new room located DIRECTION of this room"

      dir_int = Exit.s_to_i rest

      if not dir_int
        game.send_msg mob, usage
      elsif mob.room.has_exit? dir_int
        game.send_msg mob, "Your room already has an exit #{dir_int}.\n"
      else
        new_room = Room.create({name:get_default_room_name(mob)})
        raise "Failed to create room" if new_room.new_record?
        Exit.create_exit mob.room, new_room, dir_int
        Exit.create_exit new_room, mob.room, Exit.reverse(dir_int)
        game.send_msg mob, "You create a room to the #{Exit.i_to_s dir_int}.\n"
      end
    end

    def room_default_name( game, mob, name )
      raise "expected mob to be a Mob" unless mob.kind_of? Mob
      usage = "room default NAME\n\n"
      usage += "sets the default name for newly created rooms\n"
      if name.empty?
        game.send_msg mob, usage
      else
        set_default_room_name mob, name
      end
      game.send_msg mob, "default room name: {!{FY#{get_default_room_name mob}\n"
    end

    def room_name( game, mob, name )
      raise "expected mob to be a Mob" unless mob.kind_of? Mob
      usage = "room name NAME\n\n"
      usage += "sets the name for the current room\n"
      if name.empty?
        game.send_msg mob, usage
      else
        mob.room.name = name
        raise "failed to save room" unless mob.room.save
        look game, mob
      end
    end

    def room_desc( game, mob, desc )
      raise "expected mob to be a Mob" unless mob.kind_of? Mob
      usage = "room description DESC\n\n"
      usage += "sets the description for the current room\n"
      if desc.empty?
        game.send_msg mob, usage
      else
        mob.room.description = desc
        raise "failed to save room" unless mob.room.save
        look game, mob
      end
    end

    def room_exit( game, mob, rest )
      raise "expected mob to be a Mob" unless mob.kind_of? Mob
      raise "expected mob to have a Room" unless mob.room
      
      usage = "room exit DIRECTION ID\n\n"
      usage += "DIRECTION: north | east | south | west | up | down\n"
      usage += "ID: destination romo id\n\n"
      usage += "creates a DIRECTION exit from your room to the destination. creates a symmetric reverse exit from the destination to your room, if possible\n"

      match = rest.match(/(?<dir>\w+)\s+(?<id>.*)\Z/)
      if not match
        game.send_msg mob, usage
        return
      end
      direction = match[:dir]
      dest_room_id = match[:id]
      Log::debug "room_exit, found dir #{direction.to_s} dest #{dest_room_id.to_s}", "building"
      
      dir_int = Exit.s_to_i direction
      dest_room = target_room dest_room_id
      
      if not dir_int
        game.send_msg mob, "No such direction.\n"
      elsif not dest_room
        game.send_msg mob, "No such destination room.\n"
      elsif mob.room.has_exit? dir_int
        game.send_msg mob, "Your room already has an exit #{Exit.i_to_s dir_int}.\n"
      else
        Exit.create_exit mob.room, dest_room, dir_int
        if dest_room.has_exit? Exit.reverse(dir_int)
          game.send_msg mob, "One-way exit created #{Exit.i_to_s dir_int}. The destination room already has an exit #{Exit.i_to_s Exit.reverse(dir_int)}.\n"
        else
          Exit.create_exit dest_room, mob.room, Exit.reverse(dir_int)
          game.send_msg mob, "Two-way exit created #{Exit.i_to_s dir_int}.\n"
        end
      end
    end

    def room_unexit( game, mob, rest )
      raise "expected mob to be a Mob" unless mob.kind_of? Mob
      raise "expected mob to have a Room" unless mob.room
      
      usage = "room unexit DIRECTION\n\n"
      usage += "DIRECTION: north | east | south | west | up | down\n\n"
      usage += "removes the DIRECTION exit from your room"
      dir_int = Exit.s_to_i rest

      if not dir_int
        game.send_msg mob, usage
      elsif mob.room.has_exit? dir_int
        mob.room.delete_exit dir_int
        game.send_msg mob, "Removed exit #{Exit.i_to_s dir_int}.\n"
      else
        game.send_msg mob, "No exit #{Exit.i_to_s dir_int} to remove.\n"
      end
    end

    def goto( game, mob, dest )
      raise "expected mob to be a Mob" unless mob.kind_of? Mob
      room = target_room dest
      if dest.empty?
        usage = "goto ID\n\n"
        usage += "teleport to the room with id ID\n"
        game.send_msg mob, usage
      elsif room
        poof game, mob, room
      else
        game.send_msg mob, "No such room.\n"
      end
    end

    def room_list( game, mob )
      raise "expected mob to be a Mob" unless mob.kind_of? Mob
      list = "{!"
      list += "{FWID   | Room Name                                  | # exits \n"
      list += "--------------------------------------------------------------------\n"

      rooms = Room.find :all

      rooms.each do |room|
        id_color = room.exits.size > 0 ? "{FC" : "{FR"
        name_color = room.exits.size > 0 ? "{FY" : "{FR"
        exit_color = room.exits.size > 0 ? "{FG" : "{FR"
        line = "#{id_color}#{room.id.to_s}"
        while line.length < 10 do line += " " end
        line += "#{name_color}#{room.name}"
        while line.length < 60 do line += " " end
        line += "#{exit_color}#{room.exits.size.to_s}"
        line += "\n"
        list += line
      end
      list += "\n{FW#{rooms.size} rooms\n"
      game.send_msg mob, list
    end

    def room_safe( game, mob )
      raise "expected mob to be a Mob" unless mob.kind_of? Mob
      mob.room.safe = !mob.room.safe
      raise "failed to save room" unless mob.room.save
      msg = "Room is now "
      if mob.room.safe
        msg += "{!{FGsafe"
      else
        msg += "{!{FRunsafe"
      end
      msg += "{@.\n"
      game.send_msg mob, msg
    end

    def room_quit( game, mob )
      raise "expected mob to be a Mob" unless mob.kind_of? Mob
      mob.room.quit = !mob.room.quit
      raise "failed to save room" unless mob.room.save
      msg = "Room is now "
      if mob.room.quit
        msg += "{!{FGquittable"
      else
        msg += "{!{FRunquittable"
      end
      msg += "{@.\n"
      game.send_msg mob, msg
    end

    def target_room( id )
      Room.find id.to_i rescue nil
    end
  end
end
