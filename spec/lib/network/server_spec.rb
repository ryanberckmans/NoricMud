require "spec_helper.rb"

describe Network::Server do
  def next_port
    $test_port += 1
  end

  it "runs on a given port" do
    expect { Network::Server.new next_port }.to_not raise_error
  end

  it "runs on a default port" do
    pending "spec_helper loads a server on default port"
    expect { Network::Server.new }.to_not raise_error
  end

  it "won't run two servers on the same port" do
    port = next_port
    expect { Network::Server.new port }.to_not raise_error
    expect { Network::Server.new port }.to raise_error
  end

  context "a server running on a port" do
    before :each do
      @server_port = next_port
      @server = Network::Server.new @server_port
    end

    subject { @server }

    it "accepts a tcp connection" do
      expect { TCPSocket.new "localhost", @server_port }.to_not raise_error
    end

    it "reports a server connection when a tcpsocket connects" do
      TCPSocket.new "localhost", @server_port
      @server.tick
      @server.next_connection.should_not be_nil
    end

    it "reports exactly one server connection when a tcpsocket connects" do
      TCPSocket.new "localhost", @server_port
      @server.tick
      @server.next_connection.should_not be_nil
      @server.next_connection.should be_nil
    end
  end
end
