require 'spec_helper'
require 'noric_mud/persistence/storage'

module NoricMud
  module Persistence
    describe Storage do
      params = { :database => :world }

      it "raises when setting an attribute on a non-existent object" do
        expect { Storage::set_attribute({ :persistence_id => 3930483, :name => :valid, :value => "valid"}.merge params) }.to raise_error
      end

      it "raises when creating an object with location_persistence_id set to a non-existent object" do
        expect { Storage::create_object({ :location_persistence_id => 3939483}.merge params) }.to raise_error
      end

      it "returns an empty hash when getting attributes for a non-exsistent object, i.e. not raising for the non-existence of the object" do
        Storage::get_attributes({:persistence_id => 203948}.merge params).should eq({})
      end

      it "returns an empty array when getting contents ids for a non-exsistent object, i.e. not raising for the non-existence of the object" do
        Storage::get_object_contents_ids({:persistence_id => 203948}.merge params).should eq([])
      end

      context "with a first object created with attributes" do
        before :each do
          @attributes = { :foo => "bar", :buddy => "omg buddy", :third_attr => "OK" }
          @persistence_id = Storage::create_object({ :attributes => @attributes }.merge params)
        end

        it "should have created the attributes" do
          Storage::get_attributes({ :persistence_id => @persistence_id }.merge params).should eq(@attributes)
        end
      end
      
      context "with a first empty object created" do
        before :each do
          @persistence_id = Storage::create_object params
        end

        it "raises if a valid location is set for a non-existent object" do
          expect { Storage::set_location({ :persistence_id => 234235, :location_persistence_id => @persistence_id}.merge params) }.to raise_error
        end

        it "raises if a non-existent location is set for a valid object" do
          expect { Storage::set_location({ :persistence_id => @persistence_id, :location_persistence_id => 203943}.merge params) }.to raise_error
        end

        it "changes attribute hash size from 0 to 1 after set_attribute is called" do
          expect { Storage::set_attribute({ :persistence_id => @persistence_id, :name => :foo, :value => "valid"}.merge params).to change(Storage::get_attributes({ :persistence_id => @persistence_id }.merge params).size).from(0).to(1) }
        end

        it "raises on setting an attribute with empty value" do
          expect { Storage::set_attribute({ :persistence_id => @persistence_id, :name => "valid234", :value => ""}.merge params) }.to raise_error(Sequel::DatabaseError)
        end

        it "raises on setting an attribute with empty name" do
          expect { Storage::set_attribute({ :persistence_id => @persistence_id, :name => "", :value => "not empty"}.merge params) }.to raise_error(Sequel::DatabaseError)
        end
        
        context "setting an attribute" do
          before :each do
            @name = :attr_name
            @value = "value1"
            Storage::set_attribute({ :persistence_id => @persistence_id, :name => @name, :value => @value}.merge params)
          end

          def get_attr
            Storage::get_attributes({ :persistence_id => @persistence_id, :database => :world})[@name]
          end

          it "can return the set attribute" do
            get_attr.should eq(@value)
          end

          it "can update the existing attribute" do
            @value2 = "updated value"
            expect { Storage::set_attribute({ :persistence_id => @persistence_id, :name => @name, :value => @value2}.merge params) }.to change{get_attr}.from(@value).to(@value2)
          end
        end

        it "allows an attribute to be set and updated" do
          expect {
            
            Storage::set_attribute({ :persistence_id => @persistence_id, :name => :foo, :value => "valid2"}.merge params)
          }.to_not raise_error
        end

        it "allows setting location to object1 when creating another object" do
          expect { Storage::create_object( { :location_persistence_id => @persistence_id }.merge params)}.to change{Storage::get_object_contents_ids({ :persistence_id => @persistence_id, :database => :world}).size}.from(0).to(1)
        end
        
        context "with a second empty object created" do
          before :each do
            @persistence_id2 = Storage::create_object params
          end

          it "allows set_location on the existing objects" do
            def object1_in_object2
              Storage::set_location({ :persistence_id => @persistence_id, :location_persistence_id => @persistence_id2, :database => :world})
            end
            def object2_contents_size
              Storage::get_object_contents_ids({ :persistence_id => @persistence_id2, :database => :world}).size
            end
            expect { object1_in_object2 }.to change{object2_contents_size}.from(0).to(1)
          end
        end # second object created   
      end # first object created
    end
  end
end
