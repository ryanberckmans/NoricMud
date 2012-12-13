require 'spec_helper'
require 'noric_mud/object_parts/long_name'

describe NoricMud::ObjectParts::LongName do
  class IncludeLongName
    include NoricMud::ObjectParts::LongName
  end

  subject { IncludeLongName.new }
  
  it "calls get_attribute :long_name on long_name()" do
    subject.should_receive(:get_attribute).once.with(:long_name)
    subject.long_name
  end

  it "calls set_attribute with new long_name on long_name=" do
    new_long_name = "new long name"
    subject.should_receive(:set_attribute).once.with(:long_name, new_long_name)
    subject.long_name = new_long_name
  end
end
