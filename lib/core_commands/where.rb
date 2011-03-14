
module CoreCommands
  def self.where( game, mob )
    where = "{@Players in your vicinity:\n"
    where +=  "-------------------------\n"
    game.all_connected_characters.each do |char|
      Log::debug "found char #{char.name} mob #{char.mob.to_s} room #{char.mob.room.to_s}", "where"
      next if char.mob == mob
      line = "{FU[{@#{char.name}"
      while line.length < 30 do line += " " end
      line += "{FU]{FC - #{char.mob.room.name}\n"
      where += line
    end
    game.send_msg mob, where
  end
end
