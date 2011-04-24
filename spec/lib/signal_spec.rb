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

      it "disconnect raises if not connected" do
        expect { @connector.disconnect }.to raise_error
      end

      # add_connector( signal, connector) -> Nil
      context "with an instance of Signal, added the connector" do
        before :each do
          @signal = Driver::Signal.new
          @sig = :boomboom
          @signal.add_connector @sig, @connector
        end

        it "fires the callback" do
          @signal.fire @sig
          @proc_i.should == 1
        end

        it "fires multiple times" do
          @signal.fire @sig
          @proc_i.should == 1
          @signal.fire @sig
          @proc_i.should == 2
          @cond = false
          @signal.fire @sig
          @proc_i.should == 2
          @cond = true
          @signal.fire @sig
          @proc_i.should == 3
        end

        it "raises if a connected connector is added" do
          expect { @signal.add_connector @sig, @connector }.to raise_error
        end

        it "fires two connectors on the same signal" do
          c2 = Driver::Signal::Connector.new ->{ @proc_i += 1 }
          @signal.add_connector @sig, c2
          @proc_i.should == 0
          @signal.fire @sig
          @proc_i.should == 2
        end
      end
      
      context "with a disconnect proc assigned" do
        before :each do
          @disconnect = 0
          @connector.disconnect = ->{ @disconnect += 1 }
        end
        
        it "connected? returns true when a disconnect proc is assigned" do
          @connector.connected?.should be_true
        end

        it "disconnect() calls disconnect_proc after its assigned" do
          @connector.disconnect
          @disconnect.should == 1
        end

        it "is not connected after a disconnect" do
          @connector.disconnect
          @connector.connected?.should be_false
        end
      end # context disconnect proc assigned
    end # context /w proc and condition block

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
  end # context Signal::Connector

  context "instance" do
    before :each do
      @signal = Driver::Signal.new
    end

    # connect( signal, proc, &condition_block=nil ) -> Connector
    context "connect" do
      pending "returns a Connector"
      pending "the returned Connector is connected"
      pending "firing the returned Connector callsback if cond_block is nil"
      pending "firing the returned Connector callsback iff condition_block passes"
      pending "adding a callback to two diff signals works"
      pending "adding a callback to the same signal twice works"
      pending "firing the signal multiple times works"
      pending "calling disconnect on the returned Connector works"
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
