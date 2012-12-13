require 'spec_helper'
require 'noric_mud/object_parts/short_name'

class IncludeShortName
  include NoricMud::ObjectParts::ShortName
end

describe IncludeShortName do
  it "calls get_attribute :short_name on short_name()" do
    subject.should_receive(:get_attribute).once.with(:short_name)
    subject.short_name
  end

  it "calls set_attribute with new short_name on short_name=" do
    new_short_name = "new short name"
    subject.should_receive(:set_attribute).once.with(:short_name, new_short_name)
    subject.short_name = new_short_name
  end
end
