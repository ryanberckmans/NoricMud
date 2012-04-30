module NoricMud
  module Persistence
    class PersistedMudObject < ActiveRecord::Base
      def initialize mutex=Mutex.new
        @mutex = mutex
      end

      def async_save mud_object
        @mutex.synchronize { copy_from_transient mud_object }
        Persistence::async { @mutex.synchronize { self.save } }
        nil
      end

      protected
      # invoked by PersistedMudObject#async_save to copy state from transient mud_object into this PersistedMudObject. overridden by subclasses with specific state to copy.
      #
      # @param mud_object - transient MudObject to copy into this PersistedMudObject
      # 
      # @api protected
      def copy_from_transient mud_object
        # overridden
      end
    end
  end
end
