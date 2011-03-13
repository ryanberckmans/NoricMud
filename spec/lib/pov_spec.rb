require "spec_helper.rb"

describe "referenceable points of view with pov_static" do
  shared_examples_for "a pov_static object" do
    subject { @pov }
    it { should_not be_nil }
    its(:fake_attribute) { should be_nil }
  end

  context "an empty pov_static" do
    before :each do
      @pov = pov_static
    end
    it_behaves_like "a pov_static object"
  end

  context "a pov_static with a single key:value param" do
    before :each do
      @pov = pov_static first:"yo"
    end

    it_behaves_like "a pov_static object"
    
    it "should convert the param into an attribute" do
      @pov.first.should == "yo"
    end
  end

  context "a pov_static with a list of key:value params" do
    before :each do
      @pov = pov_static first:"yo", second:"second", third:"third", crazy_dragon_pov:"dragon"
    end

    it_behaves_like "a pov_static object"
    
    it "should convert the params into attributes" do
      @pov.first.should == "yo"
      @pov.second.should == "second"
      @pov.third.should == "third"
      @pov.crazy_dragon_pov.should == "dragon"
    end
  end
end

describe "issuing points of view with pov and pov_scope" do
  before :each do
    @povs = {}
    pov_send ->(receiver,pov) { @povs[receiver] ||= ""; @povs[receiver] += pov }
  end

  pending "should require an explicit ostream, instead of using global pov_send, perhaps using pov_scope( game )"

  it "raises error when pov(receiver) is used outside a pov_scope" do
    expect { pov("foo") do "hey" end }.to raise_error(HadPov)
  end

  it "raises error when pov_scope doesn't have a block" do
    expect { pov_scope }.to raise_error
  end

  it "allows pov to be used without a receiver" do
    expect { pov do "omg" end }.to_not raise_error
  end

  context "inside a pov_scope" do
    it "raises error when pov has no block" do
      expect { pov("foo") }.to raise_error
    end
    
    it "accepts pov objects in nested arrays" do
      pov_scope do
        pov("foo", ["fred","alice"], "jim", [["mark"]]) do "their pov!!" end
      end
    end

    it "sends the epsilon pov to reach receiver in pov_none" do
      pov_scope do
        pov_none "jim","alice"
        pov("jim","alice","fred") do "zzz" end
      end
      @povs["jim"].should == ""
      @povs["alice"].should == ""
      @povs["fred"].should == "zzz"
    end

    it "sends the pov to reach receiver after the pov_scope ends" do
      their_pov = "heyawesomepov"
      pov_scope do
        pov("foo","jim",5) do their_pov end
      end
      @povs["foo"].should == their_pov
      @povs["jim"].should == their_pov
      @povs[5].should == their_pov
    end

    it "sends the pov to reach receiver, with multiple differing pov calls, after the pov_scope ends" do
      their_pov = "heyawesomepov"
      other_pov = "abc\ndef"
      pov_scope do
        pov("foo","jim") do their_pov end
        pov(5) do other_pov end
      end
      @povs["foo"].should == their_pov
      @povs["jim"].should == their_pov
      @povs[5].should == other_pov
    end

    it "sends at most one pov to reach receiver, after the pov_scope ends" do
      a_pov = "a"
      b_pov = "b"
      c_pov = "c"
      a_original = [1,2,3]
      b_original = [4,5,6]
      c_original = [7,8,9]
      a_final = a_original
      b_final = a_original + b_original
      c_final = c_original + b_final
      pov_scope do
        pov(a_final) do a_pov end
        pov(b_final) do b_pov end
        pov(c_final) do c_pov end
      end
      a_original.each do |k| @povs[k].should == a_pov end
      b_original.each do |k| @povs[k].should == b_pov end
      c_original.each do |k| @povs[k].should == c_pov end
    end
    
  end # context in pov_scope
end
