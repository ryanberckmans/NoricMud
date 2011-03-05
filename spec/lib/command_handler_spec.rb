
describe CommandHandler do

  context "an instance" do
    before :each do
      @handler = CommandHandler.new
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

        it "raises error on push_cmd_scope" do
          expect { @handler.push_cmd_scope @mob }.to raise_error
        end

        it "raises error on pop_cmd_scope" do
          expect { @handler.pop_cmd_scope @mob }.to raise_error
        end

        it "raises error on add_handler" do
          expect { @handler.add_handler @mob, Object.new, 10 }.to raise_error
        end

        it "raises error on remove_handler" do
          expect { @handler.remove_handler @mob, Object.new }.to raise_error
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

        it "raises error on pop_cmd_scope, because no scopes have been added" do
          expect { @handler.pop_cmd_scope @mob }.to raise_error
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
        
        context "with a cmd_scope" do
          before :each do
            @handler.push_cmd_scope @mob
          end

          it "allows a single handler to be added" do
            pending
          end

          it "allows three handlers with differing priorities to be added" do
            pending
          end

          it "returns an empty array of handlers with a call to ordered_handlers" do
            pending
          end

          context "with three handlers with differing priorities added" do
            it "removes a specific handler" do
              pending
            end

            it "returns a complete and ordered array of handlers with a call to ordered_handlers" do
              pending
            end

            context "with an additional push_cmd_scope" do
              it "returns an empty array of handlesr with a call to ordered_handlers, because the newest cmd_scope is blank" do
                pending
              end
              context "when the additional cmd_scope is popped" do
                it "again behaves like when the three handlers with diff priorites were added" do
                  pending
                end
              end
            end
          end

          it "allows a pop_cmd_scope" do
            expect { @handler.pop_cmd_scope( @mob ) }.to_not raise_error
          end

          context "when the cmd_scope is popped for the mob" do
            before :each do
              @handler.pop_cmd_scope @mob
            end

            it "raises error on pop_cmd_scope, because no scopes remain" do
              expect { @handler.pop_cmd_scope( @mob ) }.to raise_error
            end
          end # context cmd_scope popped
        end # context new cmd_scope
      end # context when mob is added
    end # context with an unadded mob
  end # context an instance
end
