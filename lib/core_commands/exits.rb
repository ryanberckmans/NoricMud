
module CoreCommands
  def self.exits( game, mob )
    return unless mob.room
    room = mob.room
    exits = "{!{FUObvious exits:\n"
    Exit::DIRECTION_I_TO_S.each_pair do |dir_int, dir_string|
      next unless room.exit[dir_int]
      exit_in_dir = "#{dir_string.capitalize}"
      while exit_in_dir.length < 7 do exit_in_dir += " " end
      exit_in_dir += "- #{room.exit[dir_int].destination.name}"
      exit_in_dir += " ##{room.exit[dir_int].destination.id.to_s}" if show_room_id? mob
      exit_in_dir += "\n"
      exits += exit_in_dir
    end
    game.send_msg mob, exits
  end
end
