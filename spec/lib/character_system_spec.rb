require "spec_helper.rb"

describe CharacterSystem do

  before :each do
    @account_system = double()
    @account_system.stub(:kind_of?).with(AccountSystem).and_return true
    @character_selection = double()
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
end
