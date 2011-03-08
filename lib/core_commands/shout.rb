
module CoreCommands
  def self.shout(game, mob, msg )
    Log::debug "mob #{mob.short_name} shouts #{msg}", "game"
    msg.lstrip!
    if msg.length < 1
      game.send_msg mob, "{!{FMShout we must, but what?\n"
      return
    end
    pov_scope do
      pov(mob.char) do
        "{!{FMYou shout, '#{msg}'.\n"
      end
      pov(game.all_connected_characters) do
        "{!{FMYou hear #{mob.short_name} shout, '#{msg}'.\n"
      end
    end
  end
end
