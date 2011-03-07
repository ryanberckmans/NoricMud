
module CoreCommands
  def self.poof_out( mob )
    pov_scope do
      pov(mob) do
        "{!{FWPFFT. You disappear in a puff of white smoke.\n"
      end
      pov(mob.room.mobs) do
        "{!{FWPFFT. #{mob.short_name} disappears in a puff of white smoke.\n"
      end
    end
  end

  def self.poof_in( mob )
    pov_scope do
      pov(mob) do
        "{!{FWBANG! You appear in a burst of white smoke.\n"
      end
      pov(mob.room.mobs) do
        "{!{FWBANG! #{mob.short_name} appears in a burst of white smoke.\n"
      end
    end
  end
  
  def self.poof( game, mob, room )
    poof_out mob if mob.room
    game.move_to mob, room
    poof_in mob if mob.room
    Log::debug "mob #{mob.short_name} poofed to #{room.name}"
  end
end
