require "spec_helper"

module NoricMud
  module Persistence
    describe PersistedMob do
      before :each do
        @persisted_mob = PersistedMob.new
      end

      it "copies persisted attributes into a Mob instance on #transient" do
        @short_name = "shorty"
        @long_name = "longy longy"
        @persisted_mob.short_name = @short_name
        @persisted_mob.long_name = @long_name

        @mob = @persisted_mob.transient

        @mob.class.should eq Mob
        @mob.short_name.should eq @short_name
        @mob.long_name.should eq @long_name
      end
    end
  end
end
