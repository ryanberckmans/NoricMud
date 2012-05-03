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
        NoricMud.should_receive(:async).once.and_yield
        @persisted_mud_object.should_receive(:save).once.and_return(nil)

        @persisted_mud_object.async_save @mud_object
      end

      it "raises on #transient raises due to no transient_class" do
        expect { @persisted_mud_object.transient }.to raise_error
      end

      it "does #transient" do
        @persisted_mud_object.should_receive(:transient_class).once.and_return(Object)
        @mutex.should_receive(:synchronize).once { |&block| block.call }
        @persisted_mud_object.should_receive(:copy_persisted_attributes).with(@persisted_mud_object,an_instance_of(Object)).once

        @persisted_mud_object.transient.should_not be_nil
      end

      it "returns the same transient instance for subsequent invocations of #transient" do
        @persisted_mud_object.should_receive(:transient_class).once.and_return(Object)
        @mutex.should_receive(:synchronize).once { |&block| block.call }
        @persisted_mud_object.should_receive(:copy_persisted_attributes).with(@persisted_mud_object,an_instance_of(Object)).once

        transient = @persisted_mud_object.transient
        transient2 = @persisted_mud_object.transient
        transient.object_id.should eq(transient2.object_id)
      end
    end
  end
end
