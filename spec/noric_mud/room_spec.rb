require 'spec_helper'
require 'noric_mud/room'

module NoricMud
  describe Room do
    its("class.ancestors") { should include(ObjectParts::ShortName) }
    its("class.ancestors") { should include(ObjectParts::Description) }
  end
end
