
module CoreCommands
  def self.quit( game, mob, match )
    if match == "quit"
      pov_scope do
        pov(mob) do "{@Quitting...\n" end
        pov(mob.room.mobs) do "{@#{mob.char.name} quit.\n" end
      end
      game.logout mob.char
    else
      game.send_msg mob, "You must type out {!{FGquit{@ to quit.\n"
    end
  end
end
