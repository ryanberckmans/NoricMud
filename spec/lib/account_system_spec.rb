require "spec_helper.rb"

describe AccountSystem do
  def next_port
    $test_port += 1
  end

  before :each do
    @port = next_port
    @network = Network.new @port
    @auth = Authentication.new @network
  end
  
  it "should require a Network on init" do
    expect { AccountSystem.new nil, @auth }.to raise_error
    expect { AccountSystem.new @network, @auth }.to_not raise_error
  end

  it "should require an Authentication on init" do
    expect { AccountSystem.new @network, nil }.to raise_error
    expect { AccountSystem.new @network, @auth }.to_not raise_error
  end
end
