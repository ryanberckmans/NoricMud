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
      @port = next_port
      @server = TCPServer.new @port
      @client_socket = TCPSocket.new "localhost", @port
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
    it "should not be disconnected" do
      subject.tick
      subject.client_disconnected.should be_false
    end

    it "should disconnect when the tcpsocket disconnects" do
      @client_socket.close
      @connection.tick
      @connection.client_disconnected.should be_true
    end

    it "should disconnect when initialized with a disconnected tcpsocket" do
      client_socket = TCPSocket.new "localhost", @port
      server_socket = @server.accept
      client_socket.close
      connection = Network::Connection.new server_socket
      connection.tick
      connection.client_disconnected.should be_true
    end

    it "should recognize the epsilon command" do
      @client_socket.send "\n", 0
      @connection.tick
      @connection.next_command.should == ""
    end

    it "should resolve multiple newlines into multiple epsilon commands" do
      @client_socket.send "\n\n\n", 0
      @connection.tick
      @connection.next_command.should == ""
      @connection.next_command.should == ""
      @connection.next_command.should == ""
      @connection.next_command.should be_nil
    end

    it "should receive a simple command" do
      @client_socket.send "abc\n", 0
      @connection.tick
      @connection.next_command.should == "abc"
    end

    it "should receive commands in the order they are sent" do
      @client_socket.send "abc\n", 0
      @client_socket.send "def\n", 0
      @connection.tick
      @connection.next_command.should == "abc"
      @connection.next_command.should == "def"
    end

    it "should discard previous commands if the client sends --" do
      @client_socket.send "abc\ndef\n--qed\n", 0
      @connection.tick
      @connection.next_command.should == "qed"
    end

    it "should discard a newline trailing --" do
      @client_socket.send "abcet\ndddef\n--\nfged\n", 0
      @connection.tick
      @connection.next_command.should == "fged"
    end

    it "should discard previous commands up to the most recent --" do
      @client_socket.send "abc\ndef\n--qed\n--omg\nfred\r\n--\nc heal bro\n", 0
      @connection.tick
      @connection.next_command.should == "c heal bro"
    end
  end
end
