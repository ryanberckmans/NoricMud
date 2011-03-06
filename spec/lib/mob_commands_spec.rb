
describe MobCommands do

  it "requires a Game" do
    game = double("Game")
    game.stub(:kind_of?).with(Game).and_return true
    expect { MobCommands.new nil }.to raise_error
    expect { MobCommands.new 5 }.to raise_error
    expect { MobCommands.new game }.to_not raise_error
  end

  context "an instance" do
    before :each do
      @game = double("Game")
      @game.stub(:kind_of?).with(Game).and_return true
      @mob_commands = MobCommands.new @game
    end

    subject { @mob_commands }

    context "with an unadded mob" do
      before :each do
        @mob = double("Mob")
      end

      shared_examples_for "mob doesn't exist" do
        it "raises error on remove" do
          expect { @mob_commands.remove @mob }.to raise_error
        end

        it "raises error on add_cmd_handler" do
          expect { @mob_commands.add_cmd_handler @mob, Object.new, 10 }.to raise_error
        end

        it "raises error on remove_cmd_handler" do
          expect { @mob_commands.remove_cmd_handler @mob, Object.new }.to raise_error
        end

        it "raises error on handle_cmd" do
          expect { @mob_commands.handle_cmd @mob, "somecmd" }.to raise_error
        end

        it "allows mob to be added" do
          expect { @mob_commands.add @mob }.to_not raise_error
        end
      end # shared examples mob doesn't exist

      it_behaves_like "mob doesn't exist"
      
      context "after mob is added" do
        before :each do
          @mob_commands.add @mob
        end

        it "returns nil false a call to handle_cmd, because there are no handlers" do
          @mob_commands.handle_cmd(@mob, "somecmd").should be_false
        end

        it "allows mob to be removed" do
          expect { @mob_commands.remove @mob }.to_not raise_error
        end

        context "and mob is then removed" do
          before :each do
            @mob_commands.remove @mob
          end
          it_behaves_like "mob doesn't exist"
        end

        it "raises error unless added cmd handler is a CommandHandler or Proc" do
          priority = 5
          expect { @mob_commands.add_cmd_handler @mob, nil, priority }.to raise_error
          expect { @mob_commands.add_cmd_handler @mob, 5, priority }.to raise_error
          expect { @mob_commands.add_cmd_handler @mob, Object.new, priority }.to raise_error
          expect { @mob_commands.add_cmd_handler @mob, CommandHandler.new, priority }.to_not raise_error
          expect { @mob_commands.add_cmd_handler @mob, ->{}, priority }.to_not raise_error
        end
        
        it "allows a single handler to be added" do
          handler = CommandHandler.new
          priority = 5
          expect { @mob_commands.add_cmd_handler @mob, handler, priority }.to_not raise_error
        end

        it "allows three handlers with differing priorities to be added" do
          h1 = CommandHandler.new
          h2 = CommandHandler.new
          h3 = CommandHandler.new
          p1 = 1
          p2 = 5
          p3 = 500
          expect { @mob_commands.add_cmd_handler @mob, h1, p1 }.to_not raise_error
          expect { @mob_commands.add_cmd_handler @mob, h2, p2 }.to_not raise_error
          expect { @mob_commands.add_cmd_handler @mob, h3, p3 }.to_not raise_error
        end

        context "with one handler added" do
          before :each do
            @default_called = false
            @default = ->(game,char,rest,match){ @default_called = true }
            @priority = 10
            @handler = CommandHandler.new @default
            @cmd_say_called = false
            @cmd_say = ->(game,char,rest,match){ @cmd_say_called = true; @rest = rest }
            @handler.add "say", @cmd_say
            @mob_commands.add_cmd_handler @mob, @handler, @priority
          end

          it "calls default callback with handle_cmd epsilon" do
            @default_called.should be_false
            @mob_commands.handle_cmd @mob, ""
            @default_called.should be_true
          end

          it "raises an error if handle_cmd is called without a String" do
            expect { @mob_commands.handle_cmd @mob, 5 }.to raise_error
            expect { @mob_commands.handle_cmd @mob, nil }.to raise_error
            expect { @mob_commands.handle_cmd @mob, "abc" }.to_not raise_error
          end

          it "calls say correctly with handle_cmd say" do
            @cmd_say_called.should be_false
            @mob_commands.handle_cmd(@mob, "say hey").should be_true
            @rest.should == "hey"
            @cmd_say_called.should be_true
          end

          it "same handle_cmd does same thing twice" do
            pending
          end
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
