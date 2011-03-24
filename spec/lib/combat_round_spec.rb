require "spec_helper.rb"

describe Combat::CombatRound do

  context "an instance" do
    before :each do
      @game = double "Game"
      @round = Combat::CombatRound.new @game
    end

    it "should raise error if target_of mob isn't a Mob" do
      expect { @round.target_of Object.new }.to raise_error
    end

    it "should raise error if engaged mob isn't a Mob" do
      expect { @round.engaged? Object.new }.to raise_error
    end

    it "should raise error if aggressed attacker isn't a Mob" do
      pending
    end

    it "should raise error if aggressed defender isn't a Mob" do
      pending
    end

    it "should raise error if aggressed attacker is same as defender" do
      pending
    end

    context "with a first mob" do
      before :each do
        @first_mob = double "Mob"
        @first_mob.stub(:kind_of?).with(Mob).and_return true
        @first_mob.stub(:short_name).and_return "fred"
        @first_mob.stub(:state).and_return "standing"
      end

      it "should find nil as the target_of first mob" do
        @round.target_of(@first_mob).should be_nil
      end

      it "should return that the first mob is not engaged" do
        @round.engaged?(@first_mob).should be_false
      end

      context "with a second mob" do
        before :each do
          @second_mob = double "Mob"
          @second_mob.stub(:kind_of?).with(Mob).and_return true
          @second_mob.stub(:short_name).and_return "jim"
          @second_mob.stub(:state).and_return "standing"
        end

        it "should find nil as the target_of second mob" do
          @round.target_of(@second_mob).should be_nil
        end

        it "should return that the second mob is not engaged" do
          @round.engaged?(@second_mob).should be_false
        end

        shared_examples_for "first and second mob fighting" do
          it "should say the first mob is engaged" do
            @round.engaged?(@first_mob).should be_true
          end

          it "should say the second mob is engaged" do
            @round.engaged?(@second_mob).should be_true
          end

          it "should say the second mob is the target of the first mob" do
            @round.target_of(@first_mob).should == @second_mob
          end

          it "should say the first mob is the target of the second mob" do
            @round.target_of(@second_mob).should == @first_mob
          end

          it "should silently accept a redundant aggress( first, second )" do
            @round.aggress( @first_mob, @second_mob )
          end

          it "should silently accept a redundant aggress( second, first )" do
            @round.aggress( @second_mob, @first_mob )
          end
        end # shared_examples_for first and second mob fighting

        context "when a second mob agresses a first mob" do
          before :each do
            @round.aggress( @second_mob, @first_mob )
          end
          
          it_behaves_like "first and second mob fighting"
        end

        context "when a first mob agresses a second mob" do
          before :each do
            @round.aggress( @first_mob, @second_mob )
          end
          
          it_behaves_like "first and second mob fighting"

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

            context "when the first mob disengages during the three-way melee" do
              it "should find the second mob is not engaged" do
                pending
              end

              it "should find the third mob is not engaged" do
                pending
              end
            end

            context "when the second mob disengages during the three-way melee" do
              it "should find the target of the first mob is the third mob" do
                pending
              end
            end
          end # context third mob agresses first mob
        end # context first mob agresses second mob
      end # context with a second mob
    end # context with a first mob
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

  pending "setting engaged/targets manually, for abilities like rescue or mind control"
end
