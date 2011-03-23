module PhysicalState
  class Standing
    class << self
      def to_s
        "" # Standing is special in that its string is epsilon "is here", not "is standing here"
      end
      def on_enter( game, mob )
        Log::debug "mob #{mob.short_name} entered standing", "state"
      end

      def on_exit( game, mob )
        Log::debug "mob #{mob.short_name} exited standing", "state"
      end
    end
  end
end
