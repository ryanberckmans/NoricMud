require "spec_helper"

module NoricMud
  module Persistence
    describe PersistedMudObject do
      before :each do
        @mutex = double Mutex
        @persisted_mud_object = PersistedMudObject.new @mutex
      end

      it "does #async_save" do
        @mud_object = double
        @mutex_synchronized = 0
        @mutex.should_receive(:synchronize).twice { |&block| block.call; @mutex_synchronized += 1 }
        @persisted_mud_object.should_receive(:copy_from_transient).with(@mud_object).once
        Persistence.should_receive(:async).once.and_yield
        @persisted_mud_object.should_receive(:save).once.and_return(nil)

        @persisted_mud_object.async_save @mud_object

        @mutex_synchronized.should eq(2) # 2 = 1 for copy_from_transient + 1 for save
      end
    end
  end
end
