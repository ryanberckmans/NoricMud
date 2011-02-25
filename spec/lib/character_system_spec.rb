require "spec_helper.rb"

describe CharacterLoginSystem do

  it "desc" do
    described_class.should eq(CharacterLoginSystem)
  end

  context "brand new system" do
    subject { CharacterLoginSystem }
    its("new_connections") { should be_empty }
    its("new_disconnections") { should be_empty }
  end
end
