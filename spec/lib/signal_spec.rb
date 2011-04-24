require "spec_helper.rb"

describe "Signal" do
  context "instance of Signal::Connector" do
    before :each do
      @proc_i = 0
      @proc = ->{ @proc_i += 1 }
    end

    context "with a proc and nil condition_block" do
      before :each do
        @connector = Driver::Signal::Connector.new @proc
      end

      it "fire calls the proc if condition block is nil" do
        @connector.fire
        @proc_i.should == 1
      end
    end

    context "with a proc and condition_block" do
      before :each do
        @cond = true
        @condition_block = ->{ @cond }
        @connector = Driver::Signal::Connector.new @proc, @condition_block
      end

      it "fire calls the proc iff condition_block passes" do
        @connector.fire
        @proc_i.should == 1
        @connector.fire
        @proc_i.should == 2
        @cond = false
        @connector.fire
        @proc_i.should == 2
      end

      it "connected? returns false for a newly created Connector" do
        @connector.connected?.should be_false
      end
      
      it "connected? returns true when a disconnect proc is assigned" do
        @connector.disconnect = ->{ "disconnect!" }
        @connector.connected?.should be_true
      end
    end

    context "with a multi-arg proc and condition_block" do
      before :each do
        @proc = ->a,b,c{ @proc_i += a + b + c }
        @condition_block = ->a,b,c{ @proc_i += a + b + c; true }
        @connector = Driver::Signal::Connector.new @proc, @condition_block
      end

      it "passes multiple args to the proc and condition block" do
        @connector.fire(1,2,3)
        @proc_i.should == 12
      end
    end
    

    pending "disconnect() calls disconnect_proc after its assigned"
    pending "is not connected after a disconnect"
    pending "disconnect raises if not connected"
  end

  context "instance" do
    before :each do
      @signal = Driver::Signal.new
    end
    
    # Connector.new( proc, condition_block )
    
    # add_connector( signal, connector) -> Nil
    context "add connector" do
      pending "before add, fire signal doesn't callback"
      pending "after add, fire signal callsback"
      pending "firing the connector multiple times works"
      pending "adding a connector that's already bound to a signal raises"
      pending "add_connector returns nil"
      pending "two connectors added to same signal both fire"
    end

    # connect( signal, proc, &condition_block=nil ) -> Connector
    context "connect" do
      pending "returns a Connector"
      pending "firing the returned Connector callsback"
      pending "firing the returned Connector callsback iff condition_block passes"
      pending "adding a callback to two diff signals works"
      pending "adding a callback to the same signal twice works"
      pending "firing the signal multiple times works"
    end

    context "signal.disconnect" do
      pending "calling Signal.disconnect during a Signal.fire works"
      pending "calling Signal.disconnect during a Connector.fire works"
      pending "calling Signal.disconnect outside a fire() raises"
    end

    # Context.new( hash )
    # Context.apply( proc, priority=0 )
    context "Signal::Context" do
      pending "fire( Signal::Context ) applies the procs added with Context.apply after the callback"
      pending "applies are done in priority order"
      pending "applies with same priority are done in FIFO order"
    end
  end
end
