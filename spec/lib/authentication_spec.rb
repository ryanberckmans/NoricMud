require "spec_helper.rb"

describe Authentication do
  def next_port
    $test_port += 1
  end

  it "requires a proper Network upon init" do
    network = Network.new next_port
    expect { Authentication.new nil }.to raise_error
    expect { Authentication.new [] }.to raise_error
    expect { Authentication.new network }.to_not raise_error
    network.shutdown
  end

  context "with an active instance" do
    before :each do
      @port = next_port
      @network = Network.new @port
      @auth = Authentication.new @network
    end

    it "registers an authenticating connection after authenticate is called" do
      c = TCPSocket.new "localhost", @port
      @network.tick
      s = @network.next_connection
      @auth.authenticate s
      @auth.tick
      c.recv(1024).should_not be_empty
      @auth.size.should_not be_zero
    end

    it "ignores non-existent connection on disconnect" do
      expect { @auth.disconnect 5 }.to_not raise_error
    end

    it "doesn't trigger next_auth_fail for valid disconnect" do
      c = TCPSocket.new "localhost", @port
      @network.tick
      s = @network.next_connection
      @auth.authenticate s
      @auth.tick
      @auth.disconnect s
      @auth.next_auth_fail.should be_nil
    end

    it "doesn't trigger next_auth_success for valid disconnect" do
      c = TCPSocket.new "localhost", @port
      @network.tick
      s = @network.next_connection
      @auth.authenticate s
      @auth.tick
      @auth.disconnect s
      @auth.next_auth_success.should be_nil
    end

    it "de-lists connection as authenticating after valid disconnect" do
      c = TCPSocket.new "localhost", @port
      @network.tick
      s = @network.next_connection
      @auth.authenticate s
      @auth.tick
      @auth.disconnect s
      @auth.size.should be_zero
    end
  end
end
