require "spec_helper.rb"

describe AccountSystem do
  before :all do @x = true end
  subject { @x }
  it { should be_true }
end
