require "spec_helper"

module NoricMud
  module Persistence
    describe PersistedMudObject do

      # a dummy class including PersistedMudObject
      class PersistedFoo
        include PersistedMudObject
        def copy_from_transient mud_object
        end
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
