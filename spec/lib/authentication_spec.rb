require "spec_helper.rb"

describe Authentication do
  it "requires a proper Network upon init" do
    network = Network.new
    expect { Authentication.new nil }.to raise_error
    expect { Authentication.new [] }.to raise_error
    expect { Authentication.new network }.to_not raise_error
    network.shutdown
  end
end
