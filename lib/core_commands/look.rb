
module CoreCommands
  def self.look( game, mob )
    return unless mob.room and mob.char
    look = "{!"
    look += "{FY#{mob.room.name}"
    look += " ##{mob.room.id.to_s}" if show_room_id? mob
    look += "\n"
    look += "{FM#{mob.room.description}\n" unless not mob.room.description or mob.room.description.empty?
    mob.room.mobs.each do |mob_in_room|
      next if mob_in_room == mob
      state = ""
      state += " " unless state.empty?
      look += "{!{FG#{mob_in_room.long_name} is #{state}here"
      look += "."
      look += " {@{FW[Lost Link]" if not game.connected? mob_in_room.char
      look += "\n"
    end
    game.send_msg mob, look
    exits( game, mob )
  end
end
