require "spec_helper"

module NoricMud
  module Persistence
    describe PersistedMudObject do

      # subclass to test abstract class functionality
      class PersistedFoo < PersistedMudObject
        self.table_name = "mobs" # a valid table_name is required to instantiate PersistedFoo; piggy-back on mobs table although we don't use it
      end
      
      before :each do
        @persisted_mud_object = PersistedFoo.new
        @mutex = double "mutex"
        @mutex.stub(:synchronize).and_yield
      end

      it "raises on #transient due to no transient_class" do
        expect { @persisted_mud_object.transient }.to raise_error
      end

      it "does #transient" do
        @persisted_mud_object.should_receive(:transient_class).once.and_return(Object)
        @persisted_mud_object.should_receive(:mutex).once.and_return @mutex
        @persisted_mud_object.should_receive(:copy_persisted_attributes).with(@persisted_mud_object,an_instance_of(Object)).once

        @persisted_mud_object.transient.should_not be_nil
      end

      it "returns the same transient instance for subsequent invocations of #transient" do
        @persisted_mud_object.should_receive(:transient_class).once.and_return(Object)
        @persisted_mud_object.should_receive(:mutex).once.and_return @mutex
        @persisted_mud_object.should_receive(:copy_persisted_attributes).with(@persisted_mud_object,an_instance_of(Object)).once

        transient = @persisted_mud_object.transient
        transient2 = @persisted_mud_object.transient
        transient.object_id.should eq(transient2.object_id)
      end

      it "does #async_save with transient" do
        @transient = Object.new
        @persisted_mud_object.stub(:transient?).and_return true
        @persisted_mud_object.stub(:transient).and_return @transient
        
        @persisted_mud_object.should_receive(:copy_persisted_attributes).once.with(@transient,an_instance_of(OpenStruct))
        @persisted_mud_object.should_receive(:copy_persisted_attributes).once.with(an_instance_of(OpenStruct),@persisted_mud_object)
        NoricMud.should_receive(:async).once.and_yield
        @persisted_mud_object.should_receive(:mutex).once.and_return @mutex
        @persisted_mud_object.should_receive(:save).once.and_return(nil)
        
        @persisted_mud_object.async_save
      end

      it "does #async_save without transient" do
        @persisted_mud_object.stub(:transient?).and_return false
        NoricMud.should_receive(:async).once.and_yield
        @persisted_mud_object.should_receive(:mutex).once.and_return @mutex
        @persisted_mud_object.should_receive(:save).once.and_return(nil)

        @persisted_mud_object.async_save
      end
    end
  end
end
