require 'spec_helper'
require 'noric_mud/persistence'

module NoricMud
  describe Persistence do
    before :each do
      @identity_map = double 'IdentityMap'
      @identity_map.stub :add_object
      subject.identity_map = @identity_map

      @storage = double 'Storage'
      subject.storage = @storage
    end

    it "get_object delegates to identity_map" do
      database = :foo
      persistence_id = 42
      @identity_map.should_receive(:get_object).once.with(database,persistence_id)
      subject.get_object database, persistence_id
    end

    it "get_object returns the result of identity_map.get_object" do
      result = :result
      @identity_map.stub :get_object => result
      subject.get_object(nil,nil).should eq(result)
    end

    it "create_object passes params to Storage::create_object, deleting the :class parameter, adding the OBJECT_CLASS_MAGIC_ATTRIBUTE_NAME parameter, and serializing attribute values" do
      params = {
        :location_persistence_id => 2342,
        :attributes => {
          :age => 37,
          :hometown => [[1,2,3]],
          :desc => "Tall, oak, chestnut"
        }
      }

      object = double(Object)
      object.stub(:persistent?).and_return false
      object.stub(:location_persistence_id).and_return params[:location_persistence_id]
      object.stub(:attributes).and_return params[:attributes]
      object.stub(:database).and_return :world

      adjusted_params = {
        :database => :world,
        :location_persistence_id => params[:location_persistence_id],
        :attributes => params[:attributes].merge({ subject::Util::OBJECT_CLASS_MAGIC_ATTRIBUTE_NAME => object.class.to_s })
      }
      adjusted_params[:attributes].each_key do |name|
        adjusted_params[:attributes][name] = subject::Util::serialize(adjusted_params[:attributes][name] )
      end
      @storage.should_receive(:create_object).once.with(adjusted_params)

      subject::create_object object
    end

    it "create_object raises if object is already persistent" do
      object = double Object
      object.stub(:persistent?).and_return true
      expect { subject::create_object object }.to raise_error(/must be transient/)
    end

    it "create_object does not mutate the passed attributes" do
      attributes = {
        :age => 37,
        :hometown => [[1,2,3]],
        :desc => "Tall, oak, chestnut"
      }
      object = double(Object)
      object.stub(:persistent?).and_return false
      object.stub(:location_persistence_id).and_return 2342
      object.stub(:attributes).and_return attributes
      object.stub(:database).and_return :world
      attributes_clone = attributes.clone
      attributes.freeze
      @storage.should_receive :create_object
      subject::create_object object
      attributes.should eq(attributes_clone)
    end
    
    it "create_object returns the result of Storage::create_object" do
      result = 23423
      @storage.should_receive(:create_object).once.and_return(result)
      subject::create_object(Object.new).should eq(result)
    end

    it "create_object adds the object to identity_map" do
      persistence_id = 23943
      @storage.stub :create_object => persistence_id
      object = Object.new
      @identity_map.should_receive(:add_object).once.with(persistence_id,object)
      subject::create_object(object).should
    end

    it "set_location passes params to Storage::set_location" do
      params = {}
      @storage.should_receive(:set_location).once.with params
      subject::set_location params
    end

    it "set_location returns nil" do
      result = Object.new
      @storage.should_receive(:set_location).once.and_return(result)
      subject::set_location(nil).should be_nil
    end

    it "set_attribute passes params to Storage::set_attribute" do
      params = {}
      @storage.should_receive(:set_attribute).once.with params
      subject::set_attribute params
    end

    it "set_attribute returns nil" do
      result = Object.new
      @storage.should_receive(:set_attribute).once.and_return(result)
      subject::set_attribute({}).should be_nil
    end

    it "set_attribute serializes the value it passes to Storage::set_attribute" do
      params = { :value => "serialize me!" }
      params_serialized = { :value => subject::Util::serialize(params[:value]) }
      @storage.should_receive(:set_attribute).once.with(params_serialized)
      subject::set_attribute params
    end
  end
end
