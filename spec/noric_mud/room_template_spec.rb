require 'spec_helper'
require 'noric_mud/room_template'

module NoricMud
  describe RoomTemplate do
    its("class.ancestors") { should include(ObjectParts::ShortName) }
    its("class.ancestors") { should include(ObjectParts::Description) }

    pending "well this room_instance_id stuff was fun to spec, but an Object should only know about itself and its subtree"

    it { expect {subject.add_room_instance_id 0}.to change {subject.each_room_instance_id.to_a.size}.from(0).to(1) }
    it { subject.add_room_instance_id(777).should be_nil }
    
    context "added a room_instance_id" do
      before :each do
        subject.add_room_instance_id 55
      end
      its(:each_room_instance_id) { should include(55) }
      it { expect {subject.add_room_instance_id 55}.to raise_error }
      it { expect {subject.delete_room_instance_id 55}.to change {subject.each_room_instance_id.to_a.size}.from(1).to(0) }
      it { expect {subject.delete_room_instance_id 55}.to change {subject.each_room_instance_id.include? 55}.from(true).to(false) }
      it { subject.delete_room_instance_id(55).should be_nil }
      it { expect {subject.clear_room_instance_ids}.to change {subject.each_room_instance_id.to_a.size}.from(1).to(0) }
      it { subject.clear_room_instance_ids.should be_nil }
    end

    context "initialized with params" do
      subject { RoomTemplate.new({ :persistence_id => 5, :location => 7}) }
      its(:persistence_id) { should eq(5) }
      its(:location) { should eq(7) }
      its("each_room_instance_id.to_a.size") { should eq(0) }
    end

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
