
describe CommandHandler do

  context "an instance" do
    before :each do
      @handler = CommandHandler.new
    end

    subject { @handler }

    context "with a mob" do
      before :each do
        @mob = double("Mob")
        @mob_cmd_handlers = []
        @mob.stub(:cmd_handlers) do @mob_cmd_handlers end
      end

      context "and a cmd_scope for the mob" do
        before :each do
          @handler.push_cmd_scope( @mob )
        end

        it "registers the scope for the mob" do
          @handler.scope_size( @mob ).should == 1
        end

        context "when the cmd_scope is popped for the mob" do
          before :each do
            @handler.pop_cmd_scope( @mob )
          end

          it "registers the scope was popped for the mob" do
            @handler.scope_size( @mob ).should == 0
          end
        end

      end # context new cmd_scope
    end # context with a mob
  end # context an instance
end
