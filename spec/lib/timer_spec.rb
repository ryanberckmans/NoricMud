
describe Timer do
  context "instance with a signal" do
    before :each do
      @signal = double("Signal")
      @timer_proc = nil
      @signal.stub(:connect) { |sig,proc,*args| @timer_proc = proc }
      @timer = Timer.new @signal
    end

    pending "it can specify when to fire the timer (e.g. before, after tick, etc.; right now all timers fired after tick)"

    it "allows adding of a timer" do
      @timer.add 5, ->{}
    end

    it "requires that wait be non-negative" do
      expect { @timer.add 0, ->{} }.to raise_error
      expect { @timer.add -1, ->{} }.to raise_error
    end

    it "allows adding of a periodic timer" do
      @timer.add_periodic 5, ->{}, 3
    end

    it "allows adding of a periodic timer, with unspecified (infinite) repetitions" do
      @timer.add_periodic 5, ->{}
    end

    it "repeatedly fires a periodic timer" do
      @val = 0
      @f = ->{ @val += 1}
      @timer.add_periodic 2, @f
      @val.should == 0
      @timer_proc.call
      @val.should == 0
      @timer_proc.call
      @val.should == 1
      @timer_proc.call
      @timer_proc.call
      @val.should == 2
      @timer_proc.call
      @timer_proc.call
      @val.should == 3
      @timer_proc.call
      @val.should == 3
      @timer_proc.call
      @val.should == 4
    end

    it "repeatedly fires multiple periodic timers" do
      @val = 0
      @f = ->{ @val += 1}
      @g = ->{ @val += 2}
      @timer.add_periodic 2, @f
      @val.should == 0
      @timer_proc.call
      @timer.add_periodic 2, @g
      @val.should == 0
      @timer_proc.call
      @val.should == 1
      @timer_proc.call
      @val.should == 3
      @timer_proc.call
      @val.should == 4
      @timer_proc.call
      @val.should == 6
      @timer_proc.call
      @val.should == 7
      @timer_proc.call
      @val.should == 9
      @timer_proc.call
      @val.should == 10
      @timer_proc.call
      @timer_proc.call
      @val.should == 13
    end

    it "stops a periodic timer which reached its limit of repetitions" do
      @val = 0
      @f = ->{ @val += 1}
      @timer.add_periodic 1, @f, 3
      @val.should == 0
      @timer_proc.call
      @val.should == 1
      @timer_proc.call
      @val.should == 2      
      @timer_proc.call
      @val.should == 3
      @timer_proc.call
      @val.should == 3
      @timer_proc.call
      @timer_proc.call
      @val.should == 3
    end
    
    it "fires a timer at a point in the future" do
      @val = 0
      @f = ->{ @val += 1}
      @timer.add 2, @f
      @val.should == 0
      @timer_proc.call
      @val.should == 0
      @timer_proc.call
      @val.should == 1
      @timer_proc.call
      @val.should == 1
      @timer_proc.call
      @val.should == 1
    end

    it "fires a few timers at a point in the future" do
      @val = 0
      @f = ->{ @val += 1}
      @g = ->{ @val += 1}
      @timer.add 2, @f
      @timer.add 2, @g
      @timer.add 3, @g
      @timer.add 1, @f
      @timer.add 1, @g
      @val.should == 0
      @timer_proc.call
      @val.should == 2
      @timer_proc.call
      @val.should == 4
      @timer_proc.call
      @val.should == 5
      @timer_proc.call
      @val.should == 5
    end

    it "stops a periodic timer which calls Timer::stop" do
      @val = 0
      @f = ->{
        @val += 1
        Timer::stop if @val > 3
        @val += 1 if @val > 3
      }
      @timer.add_periodic 1, @f
      @val.should == 0
      @timer_proc.call
      @val.should == 1
      @timer_proc.call
      @val.should == 2
      @timer_proc.call
      @val.should == 3
      @timer_proc.call
      @val.should == 5
      @timer_proc.call
      @val.should == 5
    end
  end
end
