require "spec_helper.rb"

describe "Signal" do
  context "instance of Signal::Connector" do
    before :each do
      @proc_i = 0
      @proc = ->{ @proc_i += 1 }
    end

    context "with a proc and nil condition_proc" do
      before :each do
        @connector = Driver::Signal::Connector.new @proc
      end

      it "fire calls the proc if condition block is nil" do
        @connector.fire
        @proc_i.should == 1
      end
    end

    context "with a proc and condition_proc" do
      before :each do
        @cond = true
        @condition_proc = ->{ @cond }
        @connector = Driver::Signal::Connector.new @proc, @condition_proc
      end

      it "fire calls the proc iff condition_proc passes" do
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

        context "after connector is disconnected" do
          before :each do
            @connector.disconnect
          end
          
          it "disconnect() calls disconnect_proc after its assigned" do
            @disconnect.should == 1
          end

          it "is not connected after a disconnect" do
            @connector.connected?.should be_false
          end

          it "connector.fire still fires the proc after a disconnect" do
            @proc_i.should == 0
            @connector.fire
            @proc_i.should == 1
          end
        end # context connector disconnected
      end # context disconnect proc assigned
    end # context /w proc and condition block

    context "with a multi-arg proc and condition_proc" do
      before :each do
        @proc = ->a,b,c{ @proc_i += a + b + c }
        @condition_proc = ->a,b,c{ @proc_i += a + b + c; true }
        @connector = Driver::Signal::Connector.new @proc, @condition_proc
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
      @sig = :batcave
      @proc_i = 0
      @proc = ->{ @proc_i += 1 }
    end

    it "firing the returned Connector callsback iff condition_proc passes" do
      @cond = false
      conn = @signal.connect @sig, @proc, ->{ @cond }
      conn.fire
      @proc_i.should == 0
      @cond = true
      conn.fire
      @proc_i.should == 1
      conn.fire
      @proc_i.should == 2
      @cond = false
      @proc_i.should == 2
    end

    context "with proc connected" do
      before :each do
        @connector = @signal.connect(@sig, @proc)
      end
      
      it "firing the signal callsback" do
        @signal.fire @sig
        @proc_i.should == 1
        @signal.fire @sig
        @proc_i.should == 2
        @signal.fire @sig
        @proc_i.should == 3
      end

      it "connect returns a Connector" do
        @connector.kind_of?(Driver::Signal::Connector).should == true
      end

      it "returns a connected Connector" do
        @connector.connected?.should == true
      end

      it "firing the returned Connector callsback if cond_block is nil" do
        @connector.fire
        @proc_i.should == 1
      end

      it "works with the same proc on same signal twice" do
        @signal.connect @sig, @proc
        @proc_i.should == 0
        @signal.fire @sig
        @proc_i.should == 2
        @signal.fire @sig
        @proc_i.should == 4
      end
      
      it "works with the same proc on two diff signals" do
        @signal.connect :other, @proc
        @proc_i.should == 0
        @signal.fire @sig
        @proc_i.should == 1
        @signal.fire :other
        @proc_i.should == 2
        @signal.fire :other
        @proc_i.should == 3
        @signal.fire @sig
        @proc_i.should == 4
      end

      it "calling disconnect on the returned connector works" do
        @proc_i.should == 0
        @connector.disconnect
        @connector.connected?.should == false
        @signal.fire @sig
        @proc_i.should == 0
      end
    end # context proc connected

    it "passing data through signal.fire works" do
      proc = ->a,b{ @proc_i += a + b }
      @signal.connect @sig, proc
      @signal.fire @sig, 5, 7
      @proc_i.should == 12
      @signal.fire @sig, 0, 2
      @proc_i.should == 14
    end

    context "with a proc added that calls Signal::disconnect" do
      before :each do
        @proc = ->{ Driver::Signal::disconnect }
        @connector = @signal.connect @sig, @proc
      end

      it "calling Signal.disconnect during a Signal.fire works" do
        @connector.connected?.should be_true
        @signal.fire @sig
        @connector.connected?.should be_false
      end
      
      it "calling Signal.disconnect during a Connector.fire works" do
        @connector.connected?.should be_true
        @connector.fire
        @connector.connected?.should be_false
      end

      it "calling Signal.disconnect outside a fire() raises" do
        expect { @signal.disconnect }.to raise_error
      end
    end # context with a proc that calls Signal::disconnect

    # Context.new( hash )
    # Context.apply( proc, priority=0 )
    context "Signal::Context" do
      pending "change(priority,proc)"
      pending "fire(Signal::Context) passes the Context obj on to the callback"
      pending "a Context obj received in callback can schedule changes with obj.change { ... }"
      pending "change with priority obj.change(5) { ... }"
      pending "fire( Signal::Context ) applies three changes in priority order"
      pending "fire( Signal::Context ) applies the procs added with Context.apply after the callback"
      pending "applies are done in priority order"
      pending "applies with same priority are done in FIFO order"
    end
  end
end
