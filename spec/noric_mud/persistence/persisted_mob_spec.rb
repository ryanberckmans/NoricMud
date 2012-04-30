require "spec_helper"

module NoricMud
  module Persistence
    describe PersistedMob do
      before :each do
        @mutex = double Mutex
        @persisted_mob = PersistedMob.new @mutex
      end

      it "#async_save calls overridden copy_from_transient" do
        @short_name = "shorty"
        @long_name = "longy longy"
        @mob = double :short_name => @short_name , :long_name => @long_name

        @mutex.should_receive(:synchronize).once { |&block| block.call }
        Persistence.stub :async

        @persisted_mob.async_save @mob
        
        @persisted_mob.short_name.should eq(@short_name)
        @persisted_mob.long_name.should eq(@long_name)
      end
    end
  end
end
