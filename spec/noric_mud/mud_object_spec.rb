require "spec_helper"

module NoricMud
  describe MudObject do
    context "with persistence" do
      before :each do
        @persistence = double
        @mud_object = MudObject.new @persistence
      end

      it "returns true for persist?" do
        @mud_object.persist?.should be_true
      end

      it "calls async_save on save" do
        @persistence.should_receive(:async_save).with(@mud_object).once
        @mud_object.save
      end

      it "doesn't call persistence_class on #persist, because persistence already exists" do
        @mud_object.should_receive(:persistence_class).never
        @mud_object.persist
      end
    end

    context "without persistence" do
      before :each do
        @mud_object = MudObject.new
      end

      it "returns false for persist?" do
        @mud_object.persist?.should be_false
      end

      it "raises on #persist due to no persistence_class" do
        expect { @mud_object.persist}.to raise_error
      end

      it "returns true for persist? after calling #persist given a persistence_class" do
        @mud_object.should_receive(:persistence_class).and_return(Object)
        @mud_object.persist
        @mud_object.persist?.should be_true
      end
    end
  end
end
