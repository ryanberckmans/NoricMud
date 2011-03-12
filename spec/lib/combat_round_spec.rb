require "spec_helper.rb"

describe "Combat::CombatRound" do

  context "an instance" do

    it "should find nil as the target_of a random mob" do
      pending
    end
    
    it "should return that a random mob is not engaged" do
      pending
    end

    context "when a second mob agresses a first mob" do
      # all tests for first mob agressing second mob should pass
    end

    context "when a first mob agresses a second mob" do
      it "should say the first mob is engaged" do
        pending
      end

      it "should say the second mob is engaged" do
        pending
      end

      it "should say the second mob is the target of the first mob" do
        pending
      end

      it "should say the first mob is the target of the second mob" do
        pending
      end

      it "should silently accept a redundant aggress( first, second )" do
        pending
      end

      it "should silently accept a redundant aggress( second, first )" do
        pending
      end

      context "when a third mob agresses the first mob" do
        it "should find the third mob engaged" do
          pending
        end

        it "should still find the first mob engaged" do
          pending
        end

        it "should still find the second mob engaged" do
          pending
        end

        it "should find the target of the third mob is the first mob" do
          pending
        end

        it "should find the target of the first mob is still the second mob" do
          pending
        end

        it "should find the target of the second mob is still the first mob" do
          pending   
        end
      end # context third mob agresses first mob
    end # context first mob agresses second mob
  end # context an instance

  context "tick" do
  end

  context "aggress" do
  end

  context "target_of" do
  end

  context "engaged?" do
  end

  # CombatRound.private
  context "engage" do
  end

  context "disengage" do
  end
end
