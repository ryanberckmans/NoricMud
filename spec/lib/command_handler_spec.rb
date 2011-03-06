
describe CommandHandler do
  context "on init" do
    it "requires that non-nil default_callback be a Proc" do
      proc = double("Proc")
      proc.should_receive(:kind_of?).with(Proc).and_return true
      expect { CommandHandler.new 5 }.to raise_error
      expect { CommandHandler.new nil }.to_not raise_error
      expect { CommandHandler.new proc }.to_not raise_error
    end
  end

  context "an instance with default_callback" do
    before :each do
      @default = double("DefaultCallback")
      @default.stub(:kind_of?).with(Proc).and_return true
      @handler = CommandHandler.new @default
    end

    it "raises error if find is called with a non-string" do
      expect { @handler.find 5 }.to raise_error
      expect { @handler.find nil }.to raise_error
    end

    it "returns the default callback if find is called with epsilon" do
      @handler.find("").should == @default
    end
  end # context an instance
end
