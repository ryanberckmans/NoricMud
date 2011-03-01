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

  context "with authentication mock" do
    before :each do
      @auth = double("Authentication")
      @auth.stub(:kind_of?).with(Authentication).and_return true
      @auth.should_receive(:tick).at_least :once
      @auth.should_receive(:next_auth_fail).at_least :once
      @auth.should_receive(:next_auth_success).at_least :once
      @account = AccountSystem.new @network, @auth
    end

    it "triggers an account_connection when an account is authenticated" do
      conn = nil
      @auth.stub(:authenticate) do |c| conn = c end
      @client_socket = TCPSocket.new "localhost", @port
      @network.tick
      @account.tick
      acc = double()
      acc.should_receive(:name).at_least(:once).and_return("fred")
      accs = [{account:acc, connection:conn}]
      @auth.should_receive(:next_auth_success) do
        accs.shift
      end
      @account.tick
      acc = @account.next_account_connection
      acc.should_not be_nil
      acc.name.should == "fred"
    end

    it "sets an authenticated account online" do
      conn = nil
      @auth.stub(:authenticate) do |c| conn = c end
      @client_socket = TCPSocket.new "localhost", @port
      @network.tick
      @account.tick
      acc = double()
      acc.should_receive(:name).at_least(:once).and_return("fred")
      accs = [{account:acc, connection:conn}]
      @auth.should_receive(:next_auth_success) do
        accs.shift
      end
      @account.size.should be_zero
      @account.tick
      @account.size.should == 1
    end

    context "with one account online" do
      before :each do
        conn = nil
        @auth.stub(:authenticate) do |c| conn = c end
        @client_socket = TCPSocket.new "localhost", @port
        @network.tick
        @account.tick
        acc = double()
        acc.should_receive(:name).at_least(:once).and_return("fred")
        accs = [{account:acc, connection:conn}]
        @auth.should_receive(:next_auth_success) do
          accs.shift
        end
        @account.tick
        acc = @account.next_account_connection
        acc.should_not be_nil
        acc.name.should == "fred"
        @online_account = acc
      end

      it "triggers a disconnect on tcpdisconnect" do
        @auth.should_receive(:disconnect).exactly :once
        @client_socket.close
        @network.tick
        @network.tick
        @account.tick
        @account.next_account_disconnection.name.should == @online_account.name
      end

      it "sets the account offline on tcpdisconnect" do
        @auth.should_receive(:disconnect).exactly :once
        @client_socket.close
        @network.tick
        @network.tick
        @account.tick
        @account.size.should be_zero
      end

      context "with same already logged in account authenticated" do
        before :each do
          conn = nil
          @auth.stub(:authenticate) do |c| conn = c end
          @new_client_socket = TCPSocket.new "localhost", @port
          @network.tick
          @account.tick
          accs = [{account:@online_account, connection:conn}]
          @auth.should_receive(:next_auth_success) do
            accs.shift
          end
          old_connection = @account.connection @online_account
          @account.tick
          new_connection = @account.connection @online_account
          old_connection.should_not == new_connection
        end

        it "causes tcpdisconnect on old connection" do
          @client_socket.recv(1024)
          @client_socket.recv(1024).should == ""
        end

        it "causes account disconnect" do
          @account.next_account_disconnection.should == @online_account
        end

        it "causes account re-connection" do
          @account.next_account_connection.should == @online_account
        end

        it "still registers account as online" do
          @account.size.should == 1
        end
      end


    end # context one account online
  end # context auth mock

  context "with an active instance" do
    before :each do
      @account = AccountSystem.new @network, @auth
    end

    it "receives a new tcpconnect and begins an authentication" do
      TCPSocket.new "localhost", @port
      @network.tick
      @account.tick
      @auth.size.should == 1
    end

    it "drops the authentication on tcpdisconnect" do
      a = TCPSocket.new "localhost", @port
      @network.tick
      @account.tick
      a.close
      @network.tick
      @network.tick
      @account.tick
      @auth.size.should == 0
    end
  end
end
