
module CoreCommands
  def self.look( game, mob )
    return unless mob.room and mob.char
    look = "{!"
    look += "{FY#{mob.room.name}\n"
    look += "{FM#{mob.room.description}\n" unless not mob.room.description or mob.room.description.empty?
    mob.room.mobs.each do |mob_in_room|
      next if mob_in_room == mob
      look += "{!{FG#{mob_in_room.long_name} is here"
      if game.combat.in_combat? mob_in_room
        look += ", fighting "
        target = game.combat.target mob_in_room
        if target == mob
          look += "You!"
        else
          look += "#{target.short_name}."
        end
      else
        look += "."
      end
      look += " {@{FW[Lost Link]" if not game.connected? mob_in_room.char
      look += "\n"
    end
    game.send_msg mob, look
    exits( game, mob )
  end
end
