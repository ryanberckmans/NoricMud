module NoricMud
  module Persistence
    class PersistedMob < PersistedMudObject
      validates_presence_of :short_name, :long_name

      # populate a transient Mob equivalent of this PersistedMob
      #
      # @param mob - the transient object to populate, defaults to Mob.new
      # @return mob
      def to_transient mob=Mob.new
        mob.short_name = short_name
        mob.long_name = long_name
        mob
      end

      # called by PersistedMudObject#async_save
      private
      def copy_from_transient mob
        self.short_name = mob.short_name
        self.long_name = mob.long_name
      end
    end
  end
end
