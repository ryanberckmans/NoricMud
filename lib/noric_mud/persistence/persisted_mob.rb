module NoricMud
  module Persistence
    class PersistedMob < ActiveRecord::Base
      include PersistedMudObject
      
      validates_presence_of :short_name, :long_name


      # populate a transient Mob equivalent of this PersistedMob
      #
      # @param mob - the transient object to populate, defaults to Mob.new
      # @return mob
      def to_transient mob=Mob.new
        mob.short_name = short_name
        mob.long_name = long_name
        mob.hp_max = 250
        mob.energy_max = 100
        mob.hp = 250
        mob.energy = 100
        mob.attack_cooldown = 0.0
        mob.god = false
        mob.state = nil
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
