require "spec_helper.rb"

describe Game do
  it "requires a CharacterSystem" do
    expect {Game.new 5}.to raise_error
    expect {Game.new nil}.to raise_error
    cs = double("CharacterSystem")
    cs.stub(:kind_of?).with(CharacterSystem).and_return true
    expect {Game.new cs}.to_not raise_error
  end
end
