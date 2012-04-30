require "spec_helper"

describe NoricMud do
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

