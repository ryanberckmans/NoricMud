require 'spec_helper'
require 'noric_mud/zone_template'

module NoricMud
  describe ZoneTemplate do
    its("class.ancestors") { should include(ObjectParts::ShortName) }
    its("class.ancestors") { should include(ObjectParts::Description) }

    it { expect { add_room nil }.to raise_error }
    it { expect { add_room [] }.to raise_error }

    its(:each_room) { should be_a(Enumerator) }
    its("each_room.to_a.size") { should eq(0) }

    its(:next_room_instance_id) { should eq(0) }
    its(:next_room_instance_id) { should be_a(Fixnum) }
    it { expect { subject.__send__ :next_room_instance_id }.to change{subject.__send__ :next_room_instance_id}.by(2) } # by(2) and not by(1) since next_room_instance_id increments itself during the check

    it { expect { subject.add_room RoomTemplate.new }.to change{subject.__send__ :next_room_instance_id}.by(2) } # by(2) and not by(1) since next_room_instance_id increments itself during the check

    context "adding a room" do
      before :each do
        @template = RoomTemplate.new
        @room_instance_id = subject.add_room @template
      end
      its("each_room.to_a") { should include([@room_instance_id,@template]) }
    end

    pending "test that ZoneTemplate#initialize passes parameters to super"

    context "with some basic properties" do
      before :each do
        subject.short_name = "some short name zone style"
        subject.description = "a dark and stormy night zone style"
      end

      it "returns a newly-constructed zone on roll" do
        zone = Zone.new
        Zone.should_receive(:new).once.and_return(zone)
        output_zone = subject.roll
        output_zone.should eq(zone)
      end

      it "sets properties on the constructed zone" do
        zone = double(Zone)
        Zone.should_receive(:new).once.and_return(zone)
        zone.should_receive(:short_name=).once.with(subject.short_name)
        zone.should_receive(:description=).once.with(subject.description)
        subject.roll
      end
    end
  end
end
