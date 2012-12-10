require 'json'
require 'bijection'
require_relative "persistence/object_persistence_sequel"

module NoricMud
  module Persistence
    public

    def self.world_load object_id
    end

    def self.instance_load object_id
    end


    # R in CRUD
    # Recursively loads from db the object subtree rooted at the passed object_id
    def self.public_load object_id
      
      
      #object_attributes = AttributeModel.find :object_id => object_id

      #object = nil# construct proper object using object_attributes

      #contained_object_models = ObjectModel.find :location_object_id => object_id # Object table has index on location_object_id

      #contained_object_models.each do |contained_object_model|
      #  object.contents << load contained_object_model.id
      #end

      #object
    end

    private
      
    @@class_map = Bijection.new
    @@class_map.add NoricMud::Object, :object

    def self.class_to_value klass
      @class_map.get_y klass
    end

    def self.value_to_class value
      @class_map.get_x value
    end

    # Serialize the passed attribute value. Values are wrapped in { :data => value } so literal values don't generate json parse errors.
    #  E.g. "foo" isn't valid json, but "{ :data => "foo" }" is valid json.
    def self.serialize_attribute_value value
      { :data => value }.to_json
      # todo catch serialization errors
    end

    # Deserialize the passed attribute value. Note the { :data => value } wrapper explained above.
    def self.deserialize_attribute_value serialized_value
      (JSON.parse serialized_value)[:data]
      # todo catch parse errors
    end 
  end
end
