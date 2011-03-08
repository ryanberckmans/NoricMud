
describe Combat do

  context "Combat module" do
    it "returns an instance of Combat::Public on new" do
      pending
      Combat.new.kind_of?(Combat::Public).should be_true
    end
  end

  context "an instead of Combat::Public" do
  end
end
