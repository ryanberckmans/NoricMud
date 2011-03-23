module PhysicalState
  class Channeling
    class << self
      def to_s
        "Channeling"
      end
      
      def on_enter( game, mob )
        Log::debug "mob #{mob.short_name} entered channeling", "state"
      end

      def on_exit( game, mob )
        Log::debug "mob #{mob.short_name} exited channeling", "state"
      end
    end
  end
end
