
module CoreCommands
  def self.quit( game, mob, match )
    if match == "quit"
      game.logout mob.char
    else
      game.send_msg mob, "You must type out {!{FGquit{@ to quit.\n"
    end
  end
end
