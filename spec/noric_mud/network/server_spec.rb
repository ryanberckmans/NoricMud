require 'spec_helper.rb'

require 'noric_mud/network/server'

module NoricMud
  module Network
    describe Server do
      # I wrote Server without thinking to inject Dependencies. These examples are made to work with a real TCPSocket/Server
      
      def next_port
        $test_port ||= Random.rand(10000) + 30000
        $test_port += 1
      end

      it "runs on a given port" do
        expect { Server.new next_port }.to_not raise_error
      end

      it "runs on a default port" do
        network = nil
        expect { network = Server.new }.to_not raise_error
        network.shutdown
      end

      it "won't run two servers on the same port" do
        port = next_port
        expect { Server.new port }.to_not raise_error
        expect { Server.new port }.to raise_error
      end

      context "a server running on a port" do
        before :each do
          @server_port = next_port
          @server = Server.new @server_port
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

        it "should report any number of disconnects in a single tick" do
          conns = []
          6.times do conns << TCPSocket.new( "localhost", @server_port) end
          3.times do @server.tick end
          conns.each do |conn| conn.close end
          @server.tick
          discons = 0
          while @server.next_disconnection do discons += 1 end
          discons.should == conns.size
        end

        it "should recieve next_command sent by a tcpsocket" do
          a = TCPSocket.new "localhost", @server_port
          cmd = "hey"
          a.send cmd + "\n", 0
          @server.tick
          a_id = @server.next_connection
          @server.next_command(a_id).should == cmd
        end

        it "should not report a disconnect if the connection is disconnected on serverside" do
          a = TCPSocket.new "localhost", @server_port
          @server.tick
          a_id = @server.next_connection
          @server.disconnect a_id
          @server.tick
          @server.next_disconnection.should be_nil
        end

        it "should forward a sent msg to client tcpsocket" do
          a = TCPSocket.new "localhost", @server_port
          msg = "hey\nsexy"
          @server.tick
          a_id = @server.next_connection
          @server.send a_id, msg
          a.recv(1024).should == msg
        end
      end
    end
  end
end
