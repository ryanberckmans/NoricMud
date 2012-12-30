require 'spec_helper'
require 'noric_mud/object'

module NoricMud
  describe Object do
    pending "location= should raise if location is set to self. What about location cycles?"

    pending "modifying an attribute without calling set_attribute, such as modifying an array, won't save it. Maybe this is a don't-play-with-fire thing. #modify_attribute can yield the value and persist it afterwards, and the burden is on the programmer not to modify attributes separately. That's a bit ghetto, isn't Evennia's system entirely transparent?  You set an attribute and it's magically updated, regardles of the complexity/depth of the attribute."

    pending "the entire persistence api should be protected - i.e. accessible by other Object instances - except persist() which is really the only client-facing operation"
    
    pending "persistent? should mean 'OK to pull the plug': i.e. persistence_exists? should be renamed persistent?.  What persistent? currently is should instead be should_persist?, which uses a separate flag.  This decouples the existence of persistence from the intent to persist"

    context "requires a NoricMud::Object or nil for location=" do
      it { expect { subject.location = Object.new }.to_not raise_error }
      it { expect { subject.location = nil }.to_not raise_error }
      it { expect { subject.location = [] }.to raise_error }
    end
    
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
