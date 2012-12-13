require 'spec_helper'
require 'noric_mud/mob'

module NoricMud
  describe Mob do
    its("class.ancestors") { should include(ObjectParts::ShortName) }
    its("class.ancestors") { should include(ObjectParts::LongName) }
    its("class.ancestors") { should include(ObjectParts::Description) }
    its("class.ancestors") { should include(ObjectParts::Gender) }
  end
end
