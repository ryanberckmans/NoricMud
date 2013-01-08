require 'spec_helper'
require 'noric_mud/object'

module NoricMud
  describe Object do
    before :each do
      @persistence = double "Persistence"
      Object.persistence = @persistence
    end
    
    pending "modifying an attribute without calling set_attribute, such as modifying an array, won't save it. Maybe this is a don't-play-with-fire thing. #modify_attribute can yield the value and persist it afterwards, and the burden is on the programmer not to modify attributes separately. That's a bit ghetto, isn't Evennia's system entirely transparent?  You set an attribute and it's magically updated, regardles of the complexity/depth of the attribute."

    pending "#location_persistence_id should be protected (or not exist at all)"

    context "a subclass overriding database" do
      class Subclass < Object
        def self.database
          :another_database
        end
      end
      subject { Subclass.new }
      its(:database) { should eq(:another_database) }
    end
    
    context "with a persistent Object" do
      before :each do
        @persistence_id = 392348
        @persistence.should_receive(:create_object).once.and_return @persistence_id

        # Do not use 'subject' for our persisted object because the subject block is not evaluated until first referenced in an example
        @object = Object.new
        @object.persist
      end
      
      it "persist doesn't call create_object, because persistence already exists" do
        @persistence.should_not_receive :create_object
        @object.persist
      end

      it "location= calls set_location" do
        location = Object.new
        @persistence.should_receive(:set_location).once do |params|
          params[:persistence_id].should eq(@persistence_id)
          params[:location_persistence_id].should be_nil
        end
        @object.location = location
      end
    end

    it "raises TransientObjectError on Marshal.dump because Object is transient" do
      expect { Marshal.dump subject }.to raise_error(TransientObjectError)
    end

    it "delegates Object._load to persistence_get_object" do
      persistence_id_string = "2343"
      @persistence.should_receive(:get_object).once.with(Object.database,persistence_id_string.to_i)
      Object._load persistence_id_string
    end

    context "with a contained persistent object" do
      before :each do
        @persistence_id = 3909482309
        @contained_object = Object.new
        @persistence.should_receive(:create_object).with(@contained_object).once.and_return @persistence_id
        @contained_object.persist
        @persistence.should_receive(:set_location).once do |params|
          params[:persistence_id].should eq(@persistence_id)
          params[:location_persistence_id].should be_nil
        end
        @contained_object.location = subject
      end

      it "calls set_location with contained object's location_persistence_id when subject is saved" do
        subject_persistence_id = 902384092
        @persistence.should_receive(:create_object).once.with(subject).and_return subject_persistence_id
        @persistence.should_receive(:set_location).once do |params|
          params[:persistence_id].should eq(@persistence_id)
          params[:location_persistence_id].should eq(subject_persistence_id)
        end
        subject.persist
      end
    end

    context "with some contained transient objects" do
      before :each do
        @contained_object1 = Object.new
        @contained_object1.location = subject
        @contained_object2 = Object.new
        @contained_object2.location = subject
      end

      it "persist calls location=self on the contained object" do
        @persistence.should_receive(:create_object).with(subject).once
        @contained_object1.should_receive(:location=).with(subject).once
        @contained_object2.should_receive(:location=).with(subject).once
        subject.persist
      end
    end

    it "persist sets persistence_id returned by persistence, when creating new persistence" do
      persistence_id = 203948230948
      @persistence.stub :create_object => persistence_id
      subject.persist
      subject.send(:persistence_id).should eq(persistence_id)
    end

    it "persist calls create_object, when creating new persistence" do
      @persistence.should_receive(:create_object).once
      subject.persist
    end

    context "requires a NoricMud::Object or nil for location=" do
      it { expect { subject.location = Object.new }.to_not raise_error }
      it { expect { subject.location = nil }.to_not raise_error }
      it { expect { subject.location = [] }.to raise_error }
    end

    it "sets a new location" do
      location = Object.new
      expect { subject.location = location }.to change { subject.location }.from(nil).to(location)
    end

    it "location= doesn't call persist() when location is nil" do
      subject.should_not_receive :persist
      subject.location = nil
    end

    it "location= doesn't call persist() when location isn't persisted" do
      subject.should_not_receive :persist
      subject.location = Object.new
    end

    it "location= calls persist() when location is persisted" do
      location = Object.new
      location_persistence_id = 23904823908
      @persistence.should_receive(:create_object).with(location).and_return location_persistence_id
      location.persist

      subject.should_receive :persist
      subject.location = location
    end

    it "adds object to a new location's contents" do
      location = Object.new
      expect { subject.location = location }.to change { location.contents.include? subject }.from(false).to(true)
    end

    it "location= doesn't touch location's contents when the new and old location are the same" do
      location = Object.new
      subject.location = location
      location.should_not_receive(:contents)
      subject.location = location
    end

    it "removes object from an old location's contents" do
      location = Object.new
      location2 = Object.new
      subject.location = location
      expect { subject.location = location2 }.to change { location.contents.include? subject }.from(true).to(false)
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
