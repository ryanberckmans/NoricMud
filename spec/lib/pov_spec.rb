require "spec_helper.rb"

describe "issuing points of view with pov and pov_scope" do
  before :each do
    @povs = {}
    pov_send ->(receiver,pov) { @povs[receiver] ||= ""; @povs[receiver] += pov }
  end

  pending "should require an explicit ostream, instead of using global pov_send, perhaps using pov_scope( send_func )"

  pending "pov_scope() shouldn't communicate with pov() and pov_none() using the Thread.current[:current_pov_scope] global"

  it "raises error when pov_scope doesn't have a block" do
    expect { pov_scope }.to raise_error
  end

  it "raises error when pov has no block" do
    expect do
      pov_scope do
        pov("foo")
      end
    end.to raise_error
  end

  it "does not call the pov block when the receiver list is empty" do
    x = true
    pov_scope do
      pov { x = false; "" }
    end
    x.should be_true
  end

  it "calls block exactly once with a non-empty list of observers, because the block execution may be expensive" do
    x = 0
    y = 0
    pov_scope do
      pov( :alice ) { y += 3; "" }
      pov( :fred, :jim, :morrison ) { x += 1; "" } 
    end
    y.should eq(3)
    x.should eq(1)
  end

  it "flattens nested observers passed to pov" do
    msg = "Mark's slash demicates Alice!"
    pov_scope do
      pov(:foo, [:fred,:alice], :jim, [[:mark]]) { msg }
    end
    @povs.each_value do |value| value.should eq(msg) end
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
end
