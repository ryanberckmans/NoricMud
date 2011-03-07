
module CoreCommands
  def self.say( game, mob, msg )
    Log::debug "mob #{mob.short_name} says #{msg}", "game"
    msg.lstrip!
    if msg.length < 1
      game.send_msg mob, "{!{FCYou say, ... whaaattt?\n"
      return
    end
    pov_scope do
      pov(mob) do
        "{!{FCYou say, '#{msg}'.\n"
      end
      pov(mob.room.mobs) do
        "{!{FC#{mob.short_name} says, '#{msg}'.\n"
      end
    end
  end
end
