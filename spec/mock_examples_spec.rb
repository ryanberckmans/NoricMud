require "spec_helper.rb"

describe "mock" do
  it "test mock" do
    server = double()
    server.stub(:omg) do |x,y| x + y end
    server.omg(5,3).should == 8
  end

  it "tests should_rec" do
    x = double()
    x.should_receive(:fred).with(anything(),anything()).twice
    x.fred "abcd", nil
    x.fred "   abc  ", 0
  end
end
