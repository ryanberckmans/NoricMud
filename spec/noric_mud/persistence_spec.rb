require 'spec_helper'
require 'noric_mud/persistence'

module NoricMud
  describe Persistence do
    pending "get_object shouldn't have a location param, and delegate to a private get_object which does allow a location parameter for recursive construction. Top-level get_objects should have set_location nil called and returned as detached, to prevent a de-sync between the object's db location and in-game location"

    it "set_location passes params to Storage::set_location" do
      params = {}
      subject::Storage.should_receive(:set_location).once.with params
      subject::set_location params
    end

    it "set_location returns the result of Storage::set_location" do
      result = Object.new
      subject::Storage.should_receive(:set_location).and_return(result)
      subject::set_location(nil).should eq(result)
    end
  end
end
