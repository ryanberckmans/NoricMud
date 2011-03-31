
module CoreCommands
  def self.quit( game, mob, match )
    if match != "quit"
      game.send_msg mob, "You must type out {!{FGquit{@ to quit.\n"
      return
    end
    if mob.room != game.respawn_room
      game.send_msg mob, "You must be in the login room to quit.\n"
      return
    end
    game.logout mob.char
  end
end
