require Util.here "standing.rb"
require Util.here "channeling.rb"
require Util.here "resting.rb"
require Util.here "meditating.rb"
require Util.here "dead.rb"

module PhysicalState
  class << self
    def transition( game, mob, state )
      orig_state = mob.state
      raise "expected transition to be to a different state" if orig_state == state
      Log::debug "mob #{mob.short_name} began transitioning from state #{orig_state.to_s} to state #{state.to_s}", "state"
      mob.state.on_exit game, mob if mob.state
      mob.state = state
      mob.state.on_enter game, mob if mob.state
      Log::debug "mob #{mob.short_name} finished transitioning from state #{orig_state.to_s} to state #{state.to_s}", "state"
    end
  end
end
