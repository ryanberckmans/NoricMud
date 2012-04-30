module NoricMud
  module Persistence
    module PersistedMudObject
      def initialize mutex=Mutex.new
        @mutex = mutex
      end

      # todo concise documentation for this
      def async_save mud_object
        @mutex.synchronize { copy_from_transient mud_object }
        Persistence::async { @mutex.synchronize { self.save } }
        nil
      end
    end
  end
end
