module NoricMud
  module Persistence
    class PersistedMob < PersistedMudObject
      validates_presence_of :short_name, :long_name

      private

      # overridden
      def copy_persisted_attributes from, to
        to.short_name = from.short_name
        to.long_name = from.long_name
        nil
      end

      # overridden
      def transient_class
        Mob
      end
    end
  end
end
