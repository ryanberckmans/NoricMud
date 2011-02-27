require "spec_helper.rb"

$test_port = 47383
def next_port
  $test_port += 1
end

describe Network::Connection do
  def next_port
    $test_port +=1 
  end
  
  it "should require an underlying TCPSocket" do
    expect { Network::Connection.new [] }.to raise_error
  end

  it "doesnt require the underlying TCPSocket to be connected" do
    s = TCPSocket.new "localhost", 22
    s.close
    expect { Network::Connection.new s }.to_not raise_error
  end

  context "a connection bound to a valid tcp socket" do
    before :each do
      port = next_port
      @server = TCPServer.new port
      @client_socket = TCPSocket.new "localhost", port
      @server_socket = @server.accept
      @connection = Network::Connection.new @server_socket
    end

    after :each do
      @client_socket.close rescue nil
      @server_socket.close rescue nil
      @server.close rescue nil
      @connection = nil
    end

    subject { @connection }
    it { should_not be_nil }

    it "should disconnect when the tcpsocket disconnects" do
      @client_socket.close
      @connection.tick
      @connection.client_disconnected.should be_true
    end
  end
end
