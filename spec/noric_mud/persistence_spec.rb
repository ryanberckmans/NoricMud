require 'spec_helper'
require 'noric_mud/persistence'

module NoricMud
  describe Persistence do
    pending "get_object shouldn't have a location param, and delegate to a private get_object which does allow a location parameter for recursive construction. Top-level get_objects should have set_location nil called and returned as detached, to prevent a de-sync between the object's db location and in-game location"

    it "create_object requires the :class parameter" do
      expect { subject::create_object({}) }.to raise_error(/param :class/)
    end

    it "create_object passes params to Storage::create_object, deleting the :class parameter, adding the OBJECT_CLASS_MAGIC_ATTRIBUTE_NAME parameter, and serializing attribute values" do
      params = {
        :class => Object,
        :location_persistence_id => 2342,
        :attributes => {
          :age => 37,
          :hometown => [[1,2,3]],
          :desc => "Tall, oak, chestnut"
        }
      }
      adjusted_params = {
        :location_persistence_id => params[:location_persistence_id],
        :attributes => params[:attributes].merge({ Persistence::OBJECT_CLASS_MAGIC_ATTRIBUTE_NAME => params[:class].to_s })
      }
      adjusted_params[:attributes].each_key do |name|
        adjusted_params[:attributes][name] = subject.send :serialize, adjusted_params[:attributes][name]
      end
      subject::Storage.should_receive(:create_object).once.with(adjusted_params)
      subject::create_object params
    end

    it "create_object does not mutate the passed attributes" do
      attributes = {
        :age => 37,
        :hometown => [[1,2,3]],
        :desc => "Tall, oak, chestnut"
      }
      params = {
        :class => Object,
        :location_persistence_id => 2342,
        :attributes => attributes
      }
      attributes_clone = attributes.clone
      attributes.freeze
      subject::Storage.should_receive :create_object
      subject::create_object params
      attributes.should eq(attributes_clone)
    end
    
    it "create_object returns the result of Storage::create_object" do
      result = 23423
      subject::Storage.should_receive(:create_object).once.and_return(result)
      subject::create_object({:class => Object}).should eq(result)
    end

    it "set_location passes params to Storage::set_location" do
      params = {}
      subject::Storage.should_receive(:set_location).once.with params
      subject::set_location params
    end

    it "set_location returns nil" do
      result = Object.new
      subject::Storage.should_receive(:set_location).once.and_return(result)
      subject::set_location(nil).should be_nil
    end

    it "set_attribute passes params to Storage::set_attribute" do
      params = {}
      subject::Storage.should_receive(:set_attribute).once.with params
      subject::set_attribute params
    end

    it "set_attribute returns nil" do
      result = Object.new
      subject::Storage.should_receive(:set_attribute).once.and_return(result)
      subject::set_attribute({}).should be_nil
    end

    it "set_attribute serializes the value it passes to Storage::set_attribute" do
      params = { :value => "serialize me!" }
      params_serialized = { :value => subject.send(:serialize, params[:value]) }
      subject::Storage.should_receive(:set_attribute).once.with(params_serialized)
      subject::set_attribute params
    end

    it "serialize passes the data to Marshal.dump" do
      data = [1,2,3]
      Marshal.should_receive(:dump).once.with(data)
      subject.send :serialize, data
    end

    it "serialize returns the data provided by Marshal.dump" do
      result = [1,2,3,4]
      Marshal.should_receive(:dump).once.and_return(result)
      subject.send(:serialize, "data").should eq(result)
    end

    it "deserialize passes the data to Marshal.load" do
      data = [1,2,3]
      Marshal.should_receive(:load).once.with(data)
      subject.send :deserialize, data
    end

    it "deserialize returns the data provided by Marshal.load" do
      result = [1,2,3,4]
      Marshal.should_receive(:load).once.and_return(result)
      subject.send(:deserialize, "data").should eq(result)
    end
  end
end
