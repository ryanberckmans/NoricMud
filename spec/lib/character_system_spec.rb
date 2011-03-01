require "spec_helper.rb"

describe CharacterSystem do

  before :each do
    @account_system = double("AccountSystem")
    @account_system.stub(:kind_of?).with(AccountSystem).and_return true
    @character_selection = double("CharacterSelection")
    @character_selection.stub(:kind_of?).with(CharacterSelection).and_return true
  end

  it "requires an AccountSystem on init" do
    expect { CharacterSystem.new nil, @character_selection }.to raise_error
    expect { CharacterSystem.new Object.new, @character_selection }.to raise_error
    expect { CharacterSystem.new @account_system, @character_selection }.to_not raise_error
  end

  it "requires a CharacterSelection on init" do
    expect { CharacterSystem.new @account_system, nil }.to raise_error
    expect { CharacterSystem.new @account_system, Object.new }.to raise_error
    expect { CharacterSystem.new @account_system, @character_selection }.to_not raise_error
  end

  context "as an instance" do
    before :each do
      @char = CharacterSystem.new @account_system, @character_selection
      @account_system.stub :tick
      @account_system.stub(:next_account_connection)
      @account_system.stub(:next_account_disconnection)

      @character_selection.stub :tick
      @character_selection.stub :next_char_selection
      
      @account = double("Account")
      @account.stub(:name).and_return "jimaccount"
    end
    subject { @char }

    it "should cause character selection to start when a previously offline account connects" do
      @character_selection.should_receive(:select_character).with(@account)
      @account_system.should_receive(:next_account_connection).and_return @account
      @char.tick
    end

    it "should cause character selection to disconnect when a selecting account disconnects" do
      @character_selection.should_receive(:disconnect).with(@account)
      @account_system.should_receive(:next_account_disconnection).and_return @account
      @char.tick
    end

    context "with a character selected by account" do
      before :each do
        @character = double("Character")
        @character.stub(:name).and_return "charname"
        @character_selection.should_receive(:next_char_selection).and_return({account:@account, character:@character})
        @char.tick
      end

      it "should trigger next_char_connection" do
        @char.next_character_connection.should == @character
      end

      it "should register character as connected" do
        @char.connected?(@character).should be_true
      end

      it "should associate account with the character" do
        @char.char_online_with_account(@account).should == @character
      end

      it "should list the character as online" do
        @char.online?(@character).should be_true
      end
    end

    context "with one online character" do
      before :each do
        @character = double("Character")
        @character.stub(:name).and_return "charname"
        @character_selection.should_receive(:next_char_selection).and_return({account:@account, character:@character})
        @char.tick
        @char.next_character_connection.should == @character
        @char.online?(@character).should be_true
        @char.char_online_with_account(@account).should == @character
        @char.connected?(@character).should be_true
      end

      it "should raise error if the character is selected again with the same account" do
        @character_selection.should_receive(:next_char_selection).and_return({account:@account, character:@character})
        expect { @char.tick }.to raise_error
      end

      it "should raise error if the character is selected again with a different account" do
        another_account = double("Account")
        another_account.stub(:name).and_return "anotheraccount"
        @character_selection.should_receive(:next_char_selection).and_return({account:another_account, character:@character})
        expect { @char.tick }.to raise_error
      end

      it "should receive a cmd provided by account_system" do
        cmd = "jim c healsneak"
        @account_system.should_receive(:next_command).with(@account).and_return cmd
        @char.next_command(@character).should == cmd
      end

      it "should pass a send_msg on to the account" do
        msg = "do not fear\nyou will survive"
        @account_system.should_receive(:send_msg).with(@account,msg)
        @char.send_msg(@character,msg)
      end

      context "when the account disconnects" do
        before :each do
          @account_system.should_receive(:next_account_disconnection).and_return @account
          @character_selection.should_receive(:disconnect).with @account
          @char.tick
        end

        it "character is set disconnected" do
          @char.connected?(@character).should be_false
        end
        
        it "triggers next_character_disconnection" do
          @char.next_character_disconnection.should == @character
        end

        it "should keep the character online" do
          @char.online?(@character).should be_true
        end

        context "and then account reconnects" do
          before :each do
            @char.online?(@character).should be_true
            @char.connected?(@character).should be_false
            @account_system.should_receive(:next_account_connection).and_return @account
            @char.tick
          end

          it "should set character as connected" do
            @char.connected?(@character).should be_true
          end

          it "should keep character online" do
            @char.online?(@character).should be_true
          end

          it "should trigger next_character_connection" do
            @char.next_character_connection.should == @character
          end
        end # account reconnects
      end # account disconnects
    end # with character online with account
  end # instance of CharacterSystem
end
