
module CoreCommands
  @default_names = {}
  
  class << self

    def set_default_room_name( mob, name )
      @default_names[mob] = name
    end
    
    def get_default_room_name( mob )
      @default_names[mob] ||= "New Room"
      @default_names[mob]
    end

    
    def room_id( game, mob )
      raise "expected mob to be a Mob" unless mob.kind_of? Mob
    end

    def room_create( game, mob, rest )
      raise "expected mob to be a Mob" unless mob.kind_of? Mob
      raise "expected mob to have a Room" unless mob.room
      raise "expected rest to be a String" unless rest.kind_of? String
      
      usage = "room create DIRECTION\n\n"
      usage += "DIRECTION: north | east | south | west | up | down\n"
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
    end

    def room_desc( game, mob, desc )
      raise "expected mob to be a Mob" unless mob.kind_of? Mob
    end

    def room_exit( game, mob, dir, dest )
      raise "expected mob to be a Mob" unless mob.kind_of? Mob
      # creates bidirectional symmetric exit
    end

    def room_unexit( game, mob, dir )
      raise "expected mob to be a Mob" unless mob.kind_of? Mob
      # doesn't remove symmetric exit
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
        look game, mob
      else
        game.send_msg mob, "No such room.\n"
      end
    end

    def target_room( id )
      Room.find id.to_i rescue nil
    end
  end
end
