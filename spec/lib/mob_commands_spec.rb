
describe MobCommands do

  context "an instance" do
    before :each do
      @handler = MobCommands.new
    end

    subject { @handler }

    context "with an unadded mob" do
      before :each do
        @mob = double("Mob")
      end

      shared_examples_for "mob doesn't exist" do
        it "raises error on remove" do
          expect { @handler.remove @mob }.to raise_error
        end

        it "raises error on add_cmd_handler" do
          expect { @handler.add_cmd_handler @mob, Object.new, 10 }.to raise_error
        end

        it "raises error on remove_cmd_handler" do
          expect { @handler.remove_cmd_handler @mob, Object.new }.to raise_error
        end

        it "raises error on handle_cmd" do
          expect { @handler.handle_cmd @mob, "somecmd" }.to raise_error
        end

        it "allows mob to be added" do
          expect { @handler.add @mob }.to_not raise_error
        end
      end # shared examples mob doesn't exist

      it_behaves_like "mob doesn't exist"
      
      context "after mob is added" do
        before :each do
          @handler.add @mob
        end

        it "returns nil for a call to handle_cmd, because there are no handlers" do
          @handler.handle_cmd(@mob, "somecmd").should be_nil
        end

        it "allows mob to be removed" do
          expect { @handler.remove @mob }.to_not raise_error
        end

        context "and mob is then removed" do
          before :each do
            @handler.remove @mob
          end
          it_behaves_like "mob doesn't exist"
        end
        
        it "allows a single handler to be added" do
          pending
        end

        it "allows three handlers with differing priorities to be added" do
          pending
        end

        context "with one handler added" do
          pending
        end

        context "with three handlers with differing priorities added" do
          it "removes a specific handler" do
            pending
          end
        end # context three handlers differing priorities
      end # context when mob is added
    end # context with an unadded mob
  end # context an instance
end
