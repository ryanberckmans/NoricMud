
module CoreCommands
  def self.quit( game, mob, match )
    if match != "quit"
      game.send_msg mob, "You must type out {!{FGquit{@ to quit.\n"
      return
    end
    if not mob.room.quit
      game.send_msg mob, "You may not quit here.\n"
      return
    end
    game.logout mob.char
  end
end
