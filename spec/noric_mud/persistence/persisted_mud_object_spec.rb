require "spec_helper"

module NoricMud
  module Persistence
    describe PersistedMudObject do

      # subclass to test abstract class functionality
      class PersistedFoo < PersistedMudObject
        self.table_name = "mobs" # a valid table_name is required to instantiate PersistedFoo; piggy-back on mobs table although we don't use it
      end
      
      before :each do
        @mutex = double Mutex
        @persisted_mud_object = PersistedFoo.new @mutex
      end

      it "does #async_save" do
        @mud_object = double
        @mutex_synchronized = 0
        @mutex.should_receive(:synchronize).twice { |&block| block.call }
        @persisted_mud_object.should_receive(:copy_from_transient).with(@mud_object).once
        Persistence.should_receive(:async).once.and_yield
        @persisted_mud_object.should_receive(:save).once.and_return(nil)

        @persisted_mud_object.async_save @mud_object
      end
    end
  end
end
