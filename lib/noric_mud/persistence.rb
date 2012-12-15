require 'json'
require_relative "../util"
require_relative "object"
require_relative "persistence/storage"

module NoricMud
  module Persistence

    OBJECT_CLASS_MAGIC_ATTRIBUTE_NAME = :__reserved__object_class # serialized objects set this attribute containing their class name, for construction during deserialization. The attribute name mustn't conflict with any existing attributes.

    public
    
    # R in CRUD
    # Get an object with the passed persistence_id from the db.  Constructs the object and all contained objects.
    # required params
    #   :database  - the database to get from, must be :world or :instance
    #   :persistence_id - id of the existing persistent object to get
    # optional params
    #   :location  - an instance of NoricMud::Object to set as the constructed object's location
    # @return NoricMud::Object constructed from the database object with the passed persistence_id
    def self.get_object params
      attributes = Storage::get_attributes params

      puts attributes
      
      # Attribute values are serialized when stored and must be deserialized
      attributes.each_key do |name|
        attributes[name] = deserialize attributes[name]
      end

      puts attributes
      
      raise "serialized objects must have an #{OBJECT_CLASS_MAGIC_ATTRIBUTE_NAME} attribute for construction during deserialization" unless attributes.key? OBJECT_CLASS_MAGIC_ATTRIBUTE_NAME

      object_class = Util::constantize attributes.delete OBJECT_CLASS_MAGIC_ATTRIBUTE_NAME

      object = object_class.new :location => params[:location], :attributes => attributes, :persistence_id => params[:persistence_id]
      
      Storage::get_object_contents_ids(params).each do |contained_id|
        object.contents << get_object(:database => params[:database], :persistence_id => contained_id, :location => object)
      end

      object
    end

    # C in CRUD
    # Create a new object in the database, returning its new persistence_id. The passed object will not be modified and must assign the returned persistence_id to itself
    # required params
    #   object - NoricMud::Object which will be created in the database, must not already be persistent
    # @return persistence_id of the newly created object
    def self.create_object object
      raise "object must be transient when calling create_object, i.e. object.persistence_id == nil" unless object.persistence_id.nil?
      
      params = {
        :database => object.database,
        :location_persistence_id => object.location_persistence_id,
        :attributes => object.send(:attributes)
      }
      
      # Use the object class to create an attribute with (OBJECT_CLASS_MAGIC_ATTRIBUTE_NAME, string value of class), used to reconstruct the object
      object_class_string = object.class.to_s

      params[:attributes] ||= {}
      params[:attributes] = params[:attributes].merge({ OBJECT_CLASS_MAGIC_ATTRIBUTE_NAME => object_class_string }) # merge creates a new hash; use a new hash to prevent modifications to passed attributes; the copy produced by merge is a shallow clone and could still result in unwanted mutations to the passed attributes

      params[:attributes].each_pair do |name,value|
        params[:attributes][name] = serialize value
      end
      
      Storage::create_object params
    end

    # U in CRUD
    # Set a single attribute for a persistent object
    # required params
    #   :database  - the database to use, must be :world or :instance
    #   :persistence_id - id of the existing persistent object whose attribute is being set
    #   :name - Symbol - name of the attribute to set
    #   :value - value - value of the attribute to set - must support Marshal.dump
    # @return nil
    def self.set_attribute params
      params[:value] = serialize params[:value]
      Storage::set_attribute params
      nil
    end

    # U in CRUD
    # Set the location for a persistent object
    # required params
    #   :database  - the database to use, must be :world or :instance
    #   :persistence_id - id of the existing persistent object to set the location for
    #   :location_persistence_id - existing persistent object id which is the location to set
    # @return nil
    def self.set_location params
      Storage::set_location params
      nil
    end

    # D in CRUD
    # No support to delete an object
    # No support to delete an attribute
    
    private
    
    # Serialize the passed data
    def self.serialize data
      Marshal.dump data
    end

    # Deserialize the passed serialized data
    def self.deserialize data
      Marshal.load data
    end 
  end
end
