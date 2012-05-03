module NoricMud
  module Persistence
    class PersistedMudObject < ActiveRecord::Base
      self.abstract_class = true

      def initialize mutex=Mutex.new
        super()
        @mutex = mutex
      end

      # todo concise documentation for this
      def async_save mud_object
        @mutex.synchronize { copy_from_transient mud_object }
        NoricMud::async { @mutex.synchronize { self.save } }
        nil
      end

      protected

      # subclasses of PersistedMudObject override #copy_from_transient
      # to copy the subclasses' persisted properties from the
      # transient mud_object associated with the subclass
      #  e.g. PersistedMob overrides #copy_from_transient
      #       to copy persisted properties from Mob
      def copy_from_transient mud_object
        # override in subclass
      end
    end
  end
end
