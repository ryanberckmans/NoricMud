require 'spec_helper'
require 'noric_mud/object_parts/description'

class IncludeDescription
  include NoricMud::ObjectParts::Description
end
  
describe IncludeDescription do
  it "calls get_attribute :description on description()" do
    subject.should_receive(:get_attribute).once.with(:description)
    subject.description
  end

  it "alises description() with desc()" do
    subject.method(:desc).should eq(subject.method(:description))
  end

  it "calls set_attribute with new description on description=" do
    new_description = "new long name"
    subject.should_receive(:set_attribute).once.with(:description, new_description)
    subject.description = new_description
  end
end
