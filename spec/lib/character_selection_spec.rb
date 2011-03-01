require "spec_helper.rb"

describe CharacterSelection do
  before :each do
    @account_system = double()
    @account_system.should_receive(:kind_of?).with(AccountSystem).and_return true
  end

  it "requires an AccountSystem" do
    expect { CharacterSelection.new nil }.to raise_error
    expect { CharacterSelection.new 5 }.to raise_error
    expect { CharacterSelection.new @account_system }.to_not raise_error
  end

  context "an instance" do
    before :each do
      @selection = CharacterSelection.new @account_system
      @account = double()
      @account.stub(:name).and_return("fredaccount")
    end

    it "lists account as selecting when selection begins" do
      @selection.size.should be_zero
      @selection.select_character @account
      @selection.size.should == 1
    end

    it "ignores non-existent account on disconnect" do
      expect { @selection.disconnect "foo" }.to_not raise_error
    end

    context "with one account selecting" do
      before :each do
        @selection.select_character @account
      end

      it "does not trigger next_char_selection on disconnect" do
        @selection.next_char_selection.should be_nil
        @selection.disconnect @account
        @selection.next_char_selection.should be_nil
      end

      it "does not list account as selecting after disconnect" do
        @selection.size.should == 1
        @selection.disconnect @account
        @selection.size.should == 0
      end
    end
  end
end
