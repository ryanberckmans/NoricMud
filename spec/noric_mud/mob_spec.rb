require 'spec_helper'

module NoricMud
  describe Mob do
    it "returns PersistedMob for Mob.persistence_class" do
      pending "Mob needs a test, like PersistedMob, which starts with a transient and checks values from the created/updated persist"
      Mob.persistence_class.should eq(Persistence::PersistedMob)
    end
  end
end
