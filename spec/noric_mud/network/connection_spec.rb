require 'socket'
require 'spec_helper'
require 'noric_mud/network/connection'

module NoricMud
  module Network
    describe Connection do
      # I wrote Connection without thinking to inject dependencies. These examples are made to work with a real TCPSocket

      pending "color msgs elsewhere and remove color dependency from Connection"
      
      def next_port
        $test_port ||= Random.rand(10000) + 30000
        $test_port +=1 
      end
      
      it "doesn't require the underlying TCPSocket to be connected" do
        s = TCPSocket.new "localhost", 22
        s.close
        expect { Connection.new s }.to_not raise_error
      end

      context "a connection bound to a valid tcp socket" do
        before :each do
          @port = next_port
          @server = TCPServer.new @port
          @client_socket = TCPSocket.new "localhost", @port
          @server_socket = @server.accept
          @connection = Connection.new @server_socket
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
          connection = Connection.new server_socket
          connection.tick
          connection.client_disconnected.should be_true
        end

        it "should recognize the epsilon command" do
          @client_socket.send "\n", 0
          @connection.tick
          @connection.next_command.should == ""
          @connection.next_command.should be_nil
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
          @connection.next_command.should be_nil
        end

        it "should receive commands in the order they are sent" do
          @client_socket.send "abc\n", 0
          @client_socket.send "def\n", 0
          @connection.tick
          @connection.next_command.should == "abc"
          @connection.next_command.should == "def"
          @connection.next_command.should be_nil
        end

        it "should discard previous commands if the client sends --" do
          @client_socket.send "abc\ndef\n--qed\n", 0
          @connection.tick
          @connection.next_command.should == "qed"
          @connection.next_command.should be_nil
        end

        it "should discard a newline trailing --" do
          @client_socket.send "abcet\ndddef\n--\nfged\n", 0
          @connection.tick
          @connection.next_command.should == "fged"
          @connection.next_command.should be_nil
        end

        it "should discard previous commands up to the most recent --" do
          @client_socket.send "abc\ndef\n--qed\n--omg\nfred\r\n--\nc heal bro\n", 0
          @connection.tick
          @connection.next_command.should == "c heal bro"
          @connection.next_command.should be_nil
        end

        it "dilineates commands using windows newlines" do
          @client_socket.send "abc\r\n\r\ndef\r\nomg\r\n", 0
          @connection.tick
          @connection.next_command.should == "abc"
          @connection.next_command.should == ""
          @connection.next_command.should == "def"
          @connection.next_command.should == "omg"
          @connection.next_command.should be_nil
        end

        it "requires input to be terminated by a newline to become a command" do
          @client_socket.send "abc", 0
          @connection.tick
          @connection.next_command.should be_nil
          @client_socket.send "\n", 0
          @connection.tick
          @connection.next_command.should == "abc"
        end

        it "does not process extremely large socket receipts all at once" do
          large = "heybadgerbadgerbadgermushroommushroom"
          4.times { large += large }
          @client_socket.send large + "\n", 0
          @connection.tick
          @connection.next_command.should be_nil
          20.times { @connection.tick }
          @connection.next_command.should == large
        end

        it "receives commands verbatim" do
          cmd = "saY   yO!!dawg__  how you doing?? this is some weirdly formatted command!!!    "
          @client_socket.send cmd + "\n", 0
          @connection.tick
          @connection.next_command.should == cmd
        end

        it "strips left whitespace off commands" do
          cmd = "holy command batman!!!!!wnes cheal me shockw"
          whitespace = "   \t   " 
          @client_socket.send whitespace + cmd + "\n", 0
          @connection.tick
          @connection.next_command.should == cmd
        end

        it "does not strip right whitespace off commands" do
          cmd = "holy command batman!!!!!wnes cheal me shockw           "
          @client_socket.send cmd + "\n", 0
          @connection.tick
          @connection.next_command.should == cmd
        end

        it "strips out non-printable/bad characters from commands" do
          cmd = "hey "
          cmd += 7.chr
          cmd += 0.chr
          cmd += 12.chr
          cmd += 11.chr
          (240..255).each do |i| cmd += i.chr end
          cmd += "man"
          (240..255).each do |i| cmd += i.chr end
          @client_socket.send cmd + "\n", 0
          @connection.tick
          @connection.next_command.should == "hey man"
        end

        it "doesn't report a client_disconnect when disconnect is on server side" do
          @connection.disconnect
          @connection.client_disconnected.should be_false
        end

        it "causes the client socket to disconnect when server disconnects" do
          @connection.disconnect
          @client_socket.recv(1024).should == ""
        end

        it "allows disconnecting a disconnected connection" do
          @connection.disconnect
          expect { @connection.disconnect }.to_not raise_error
        end

        it "stops reporting commands when disconnected" do
          @client_socket.send "abc\n", 0
          @connection.tick
          @connection.disconnect
          @connection.next_command.should be_nil
        end

        it "fails silently when a message is sent to a disconnected user" do
          @connection.disconnect
          expect { @connection.send "foo" }.to_not raise_error
        end

        it "can send an empty message" do
          expect { @connection.send "" }.to_not raise_error
        end

        it "can send a huge message to a client" do
          large = "heybadgerbadgerbadgermushroommushroom"
          6.times { large += large }
          @connection.send large
          @client_socket.recv(large.length + 1024).should == large
        end

        it "sends messages which are actually received verbatim by a client" do
          cmd = "abc"
          @connection.send cmd
          @client_socket.recv(1024).should == cmd
          cmd = " KILLING BLOW dEF    $%& 000033_____.????? OMG      "
          @connection.send cmd
          @client_socket.recv(1024).should == cmd
          cmd = "damn son \nholy verbatim BATMAN\r\nandrobin  393 "
          @connection.send cmd
          @client_socket.recv(1024).should == cmd
        end

        it "can not break / fail silently when sending a message to a closed client socket" do
          @client_socket.close
          expect { @connection.send "abc" }.to_not raise_error
        end

        it "fails silently when sending messages to a connection closed on the client side" do
          @client_socket.close
          expect { @connection.send "abc" }.to_not raise_error
          expect { @connection.send "def" }.to_not raise_error
          expect { @connection.send "omgponies" }.to_not raise_error
        end

        it "colorifies sent messages" do
          msg = "hey {@{!{FW{BUjim how you doing{@"
          @connection.send msg
          @client_socket.recv(1024).should == Color::color(msg)
        end

        it "leaves no color codes in a sent string" do
          msg = "hey!"
          Color::COLORS.keys.each do |color_code| msg += color_code end
          msg += msg
          @connection.send msg
          recv_msg = @client_socket.recv(2048)
          Color::COLORS.keys.each do |color_code|
            recv_msg.index(color_code).should be_nil
          end
        end

        it "correctly sends a message which is epsilon besides color codes" do
          msg = "{@{!{FW{BU"
          expect { @connection.send msg }.to_not raise_error
          @client_socket.recv(1024).should == Color::color(msg)
        end
      end
    end
  end
end
