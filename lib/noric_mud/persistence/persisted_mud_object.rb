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

      def copy_from_transient mud_object
        # override in subclass
      end
    end
  end
end
