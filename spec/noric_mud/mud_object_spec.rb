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
    end

    context "without persistence" do
      before :each do
        @mud_object = MudObject.new
      end

      it "returns false for persist?" do
        @mud_object.persist?.should be_false
      end
    end
  end
end
