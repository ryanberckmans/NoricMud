require 'spec_helper'
require 'noric_mud/persistence'

module NoricMud
  describe Persistence do
    pending "#delete_attribute"
    pending "get_object shouldn't have a location param, and delegate to a private get_object which does allow a location parameter for recursive construction. Top-level get_objects should have set_location nil called and returned as detached, to prevent a de-sync between the object's db location and in-game location"
  end
end
