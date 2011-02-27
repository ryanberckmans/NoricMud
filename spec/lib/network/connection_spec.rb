require "spec_helper.rb"

TEST_PORT = 47583

describe Network::Connection do
  it "should require an underlying TCPSocket" do
    expect { Network::Connection.new [] }.to raise_error
  end

  it "doesnt require the underlying TCPSocket to be connected" do
    s = TCPSocket.new "localhost", 22
    s.close
    expect { Network::Connection.new s }.to_not raise_error
  end

  context "a connection bound to a valid tcp socket" do
    before :each, do
      @server = TCPServer.new TEST_PORT
      @user_socket = TCPSocket.new "localhost", TEST_PORT
      @server_socket = @server.accept
      @connection = Network::Connection.new @server_socket
    end

    after :each do
      @user_socket.close
      @server_socket.close
      @server.close
      @connection = nil
    end

    subject { @connection }
    it { should_not be_nil }
  end
end
