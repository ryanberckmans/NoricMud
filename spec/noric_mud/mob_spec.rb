require 'spec_helper'

module NoricMud
  describe Mob do
    it "returns PersistedMob for Mob.persistence_class" do
      Mob.persistence_class.should eq(Persistence::PersistedMob)
    end
  end
end
