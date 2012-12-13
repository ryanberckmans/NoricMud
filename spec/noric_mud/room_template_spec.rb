require 'spec_helper'
require 'noric_mud/room_template'

module NoricMud
  describe RoomTemplate do
    its("class.ancestors") { should include(ObjectParts::ShortName) }
    its("class.ancestors") { should include(ObjectParts::Description) }

    context "with some basic properties" do
      before :each do
        subject.short_name = "some short name"
        subject.description = "a dark and stormy night"
      end

      it "returns a newly-constructed room on roll" do
        room = Room.new
        Room.should_receive(:new).once.and_return(room)
        output_room = subject.roll
        output_room.should eq(room)
      end

      it "sets properties on the constructed room" do
        room = double(Room)
        Room.should_receive(:new).once.and_return(room)
        room.should_receive(:short_name=).once.with(subject.short_name)
        room.should_receive(:description=).once.with(subject.description)
        subject.roll
      end
    end
  end
end
