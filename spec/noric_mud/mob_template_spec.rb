require 'spec_helper'
require 'noric_mud/mob_template'

module NoricMud
  describe MobTemplate do
    its("class.ancestors") { should include(ObjectParts::ShortName) }
    its("class.ancestors") { should include(ObjectParts::LongName) }
    its("class.ancestors") { should include(ObjectParts::Description) }
    its("class.ancestors") { should include(ObjectParts::Gender) }

    context "with some basic properties" do
      before :each do
        subject.gender = :male
        subject.short_name = "some short name"
        subject.long_name = "holy long name"
        subject.description = "a dark and stormy night"
      end

      it "returns a newly-constructed mob on roll" do
        mob = Mob.new
        Mob.should_receive(:new).once.and_return(mob)
        output_mob = subject.roll
        output_mob.should eq(mob)
      end

      it "sets properties on the constructed mob" do
        mob = double(Mob)
        Mob.should_receive(:new).once.and_return(mob)
        mob.should_receive(:short_name=).once.with(subject.short_name)
        mob.should_receive(:long_name=).once.with(subject.long_name)
        mob.should_receive(:description=).once.with(subject.description)
        mob.should_receive(:gender=).once.with(subject.gender)
        subject.roll
      end
    end
  end
end
