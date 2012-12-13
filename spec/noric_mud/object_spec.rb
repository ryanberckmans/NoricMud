require 'spec_helper'
require 'noric_mud/object'

module NoricMud
  describe Object do
    it "set_attribute_unless_exists sets the attribute" do
      bar = [1,2,3]
      subject.__send__ :set_attribute_unless_exists, :foo, bar
      subject.__send__(:get_attribute, :foo).should eq(bar)
    end

    context "with a non-nil attribute :foo" do
      before :each do
        @bar = 5
        subject.__send__ :set_attribute, :foo, @bar
      end

      it "set_attribute_unless_exists should not set :foo" do
        dar = "don't set me!"
        subject.__send__ :set_attribute_unless_exists, :foo, dar
        subject.__send__(:get_attribute,:foo).should eq(@bar)
      end
    end
  end
end
