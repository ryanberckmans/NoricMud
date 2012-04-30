module NoricMud
  module Persistence
    class PersistedMob < PersistedMudObject
      # #initialize inherited
      
      validates_presence_of :short_name, :long_name

      # @overridden
      def copy_from_transient mob
        short_name = mob.short_name
        long_name = mob.long_name
      end

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
    end
  end
end
