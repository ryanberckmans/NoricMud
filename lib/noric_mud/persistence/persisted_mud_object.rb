module NoricMud
  module Persistence
    class PersistedMudObject < ActiveRecord::Base
      self.abstract_class = true

      def initialize mutex=Mutex.new
        super()

        # mutex must be synchronized for any CRUD to persisted properties
        @mutex = mutex
        @transient = nil
      end

      # todo concise documentation for this
      def async_save mud_object
        @mutex.synchronize { copy_from_transient mud_object }
        NoricMud::async { @mutex.synchronize { self.save } }
        nil
      end

      # return the transient instance associated with this
      def transient
        unless @transient
          @transient = transient_class.new
          @mutex.synchronize { copy_persisted_attributes self, @transient }
        end
        @transient
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

      # subclasses of PersistedMudObject override ::transient_class
      # to return the transient class associated with the subclass
      def self.transient_class
        raise "#transient_class must be overridden"
      end
    end
  end
end
