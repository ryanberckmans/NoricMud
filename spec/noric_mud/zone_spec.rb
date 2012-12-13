require 'spec_helper'
require 'noric_mud/zone'

module NoricMud
  describe Zone do
    its("class.ancestors") { should include(ObjectParts::ShortName) }
    its("class.ancestors") { should include(ObjectParts::Description) }
  end
end
