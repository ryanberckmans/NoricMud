module PhysicalState
  class Channeling
    class << self
      def to_s
        "Channeling"
      end
      
      def on_enter( game, mob )
        Log::debug "mob #{mob.short_name} entered channeling", "state"
        raise "expected mob #{mob.short_name} to be channeling" unless game.channeling? mob
      end

      def on_exit( game, mob )
        Log::debug "mob #{mob.short_name} exited channeling", "state"
        game.cancel_channel mob
      end
    end
  end
end
