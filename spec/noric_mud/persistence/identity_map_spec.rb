require 'spec_helper'
require 'noric_mud/persistence/identity_map'

module NoricMud
  module Persistence
    describe IdentityMap do
      # Remember, IdentityMap is a singleton and unit tests require extra care      
      subject { IdentityMap.instance }
      
      it "raises error when constructing a new IdentityMap, because it's a singleton" do
        expect { IdentityMap.new }.to raise_error
      end

      it "get unknown object raises error adds an object" do
        expect { subject.get_object :world, 39393 }.to raise_error(ObjectNotFoundError)
      end

      it "adds an object" do
        object = double "Object"
        object.stub :database => :world
        object.stub :persistence_id => 37
        subject.add_object object.persistence_id, object
        subject.get_object(object.database, object.persistence_id).should eq(object)
      end

      pending "test #load_all_objects"
    end
  end
end
