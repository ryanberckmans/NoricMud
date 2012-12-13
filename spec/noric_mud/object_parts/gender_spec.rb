require 'spec_helper'
require 'noric_mud/object_parts/gender'

class IncludeGender
  include NoricMud::ObjectParts::Gender
end
  
describe IncludeGender do
  it "calls get_attribute :gender on gender()" do
    subject.should_receive(:get_attribute).once.with(:gender)
    subject.gender
  end
  
  it "calls set_attribute with new gender on gender=" do
    new_gender = :male
    subject.should_receive(:set_attribute).once.with(:gender, new_gender)
    subject.gender = new_gender
  end

  it "raises if gender isn't :male, :female, or :it" do
    new_gender = "not a real gender"
    expect { subject.gender = new_gender }.to raise_error
  end
end
