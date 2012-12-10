require 'json'
require 'bijection'
require_relative "object"
require_relative "persistence/storage"

module NoricMud
  module Persistence

    public
    
    # R in CRUD
    # Recursively loads from db the object subtree rooted at the passed object_id
    # required params
    #   :object_id - persistent object id to load
    #   :database  - database to load from, must be :world or :instance
    #   :location  - object to attach to
    # @return loaded and constructed NoricMud::Object
    def self.load_object params
      serialized_attributes = Storage::load_attributes params

      attributes = {}
      
      serialized_attributes.each_pair do |name,serialized_value|
        attributes[name] = deserialize_attribute_value serialized_value 
      end

      # TODO attribute translation.  bob[:location] -> bob.location.persistence_id and backwards on load

      raise "expected an :object_class attribute while loading object" unless attributes.key? :object_class

      object = (value_to_class attributes.delete :object_class).new :location => location, :attributes => attributes
      
      contained_object_ids = [] # TODO Storage:: get child object ids

      contained_object_ids.each do |contained_object_id|
        # object.contents << public_load contained_object_id, object
      end

      object
    end

    # C in CRUD
    # Create a new object in the database
    # optional params
    #   :location_object_id - the object_id of the persistent object containing the object being saved
    #   :attributes - attributes to save, belonging to the object being saved
    # @return persistence_id of the new 
    def self.create_object params
    end

    # U in CRUD
    # Save a single attribute for a persistent object
    # required params
    #   :persistence_id - the id of the existing persistent object
    #   :name - String - name of the attribute to save
    #   :value - value of the attribute to save. Will be serialized to json. Must implement value.to_json
    # @returns nil
    def self.save_attribute params
      params[:value] = serialize_attribute_value params[:value]
      # TODO
      nil
    end

    # U in CRUD
    # Set the location for a persistent object
    # required params
    #   :persistence_id - id of the existing persistent object to set the location for
    #   :location_persistence_id - existing persistent object id which is the location to set
    # @returns nil
    def self.set_location params
      nil
    end

    # D in CRUD
    # No support to delete an object
    # No support to delete an attribute
    
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
