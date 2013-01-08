require "spec_helper"
require "noric_mud"

describe NoricMud do
  describe "move" do
    before :each do
      @object = double NoricMud::Object
      @destination = double NoricMud::Object
      @contents = []
      
      @object.stub(:location) { @location }
      @object.stub(:location=) { nil }
      @destination.stub(:contents) { @contents }
    end

    def move
      NoricMud::move @object, @destination
    end
    
    shared_examples "a move" do
      it "adds object to destination's contents" do
        pending "mv move specs into Object"
        move
        @contents.should include @object
      end

      it "sets object.location to the destination" do
        pending "mv move specs into Object"
        @object.should_receive(:location=).with(@destination).once
        move
      end
    end

    context "with a non-nil location" do
      before :each do
        @location = double NoricMud::Object
        @location_contents = [@object]
        @location.stub(:contents) { @location_contents }
      end
      it_behaves_like "a move"

      it "removes object from location's contents" do
        pending "mv move specs into Object"
        move
        @location_contents.should_not include @object
      end
    end

    context "with a nil location" do
      before :each do
        @location = nil
      end
      it_behaves_like "a move"
    end
  end # move
  
  before :all do
    NoricMud::start_async_thread
  end

  before :each do
    NoricMud::clear_async_queue
  end
  
  it "asyncronously calls a block passed to ::async" do
    @counter = 0
    NoricMud::async { @counter += 1 }
    sleep 1
    @counter.should eq(1)
  end

  it "async return value is nil" do
    (NoricMud::async { "dummy" }).should be_nil
  end

  it "preserves order of blocks passed to ::async" do
    @data = []
    NoricMud::async { @data << 1 }
    NoricMud::async { @data << 2 }
    NoricMud::async { @data << 3 }
    sleep 1
    @data.size.should eq 3
    @data.should eq [1,2,3]
  end
end

