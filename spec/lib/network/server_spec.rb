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

    it "refuses new connections when shutdown" do
      @server.shutdown
      expect { TCPSocket.new "localhost", @server_port }.to raise_error(Errno::ECONNREFUSED)
    end

    it "disconnects all connections when shutdown" do
      a = TCPSocket.new "localhost", @server_port
      b = TCPSocket.new "localhost", @server_port
      @server.shutdown
      expect { a.recv(1024) }.to raise_error(Errno::ECONNRESET)
      expect { b.recv(1024) }.to raise_error(Errno::ECONNRESET)
    end

    it "should report a new connection when there's a tcpconnect to the server" do
      TCPSocket.new "localhost", @server_port
      @server.tick
      @server.next_connection.should_not be_nil
    end

    it "should report exactly one new connection when there's a tcpconnect to the server" do
      TCPSocket.new "localhost", @server_port
      @server.tick
      @server.next_connection.should_not be_nil
      @server.next_connection.should be_nil
    end

    it "should report exactly two new connections when there's two tcpconnects to the server" do
      TCPSocket.new "localhost", @server_port
      TCPSocket.new "localhost", @server_port
      @server.tick
      @server.next_connection.should_not be_nil
      @server.next_connection.should_not be_nil
    end

    it "should not process a flood of connections all at once" do
      6.times do TCPSocket.new "localhost", @server_port end
      @server.tick
      new_connections = 0
      while @server.next_connection do new_connections += 1 end
      new_connections.should > 2
      new_connections.should < 5
    end

    it "should ignore a tcpconnection which disconnects during the same tick it connects" do
      a = TCPSocket.new "localhost", @server_port
      a.close
      @server.tick
      @server.next_connection.should be_nil
      @server.next_disconnection.should be_nil
    end

    it "should not ignore a tcpconnection which disconnects the tick after it connects" do
      a = TCPSocket.new "localhost", @server_port
      @server.tick
      @server.next_connection.should_not be_nil
      a.close
      @server.tick
      @server.next_disconnection.should_not be_nil
    end
  end
end
