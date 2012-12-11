require 'json'
require 'bijection'
require_relative "object"
require_relative "persistence/storage"

module NoricMud
  module Persistence

    OBJECT_CLASS_MAGIC_ATTRIBUTE_NAME = :__reserved__object_class # serialized objects set this attribute containing their class name (i.e. a type of NoricMud::Object) for construction during deserialization. The attribute name mustn't conflict with any existing attributes.

    public
    
    # R in CRUD
    # Get an object with the passed persistence_id from the db.  Constructs the object and all contained objects.
    # required params
    #   :database  - the database to get from, must be :world or :instance
    #   :persistence_id - id of the existing persistent object to get
    #   :location  - an instance of NoricMud::Object to set as the constructed object's location
    # @return NoricMud::Object constructed from the database with the passed persistence_id
    def self.get_object params
      attributes = Storage::get_attributes params

      # Attribute values are serialized when stored and must be deserialized
      attributes.each_key do |name|
        attributes[name] = deserialize attributes[name]
      end

      raise "serialized objects must have an #{OBJECT_CLASS_MAGIC_ATTRIBUTE_NAME} attribute for construction during deserialization" unless attributes.key? OBJECT_CLASS_MAGIC_ATTRIBUTE_NAME

      object_class = object_class_string_to_type attributes.delete OBJECT_CLASS_MAGIC_ATTRIBUTE_NAME

      object = object_class.new :location => params[:location], :attributes => attributes, :persistence_id => params[:persistence_id]
      
      Storage::get_object_contents_ids.each do |contained_id|
        object.contents << get_object(:database => params[:database], :persistence_id => contained_id, :location => object)
      end

      object
    end

    # C in CRUD
    # Create a new object in the database
    # required params
    #   :database  - the database create in, must be :world or :instance
    # optional params
    #   :location_persistence_id - the persistence_id of the location of the object to create
    #   :attributes - { Symbol name -> value } - attributes for the new object
    #                                  value must implement .to_json
    # @return persistence_id of the newly created object
    def self.create_object params
      Storage::create_object params
    end

    # U in CRUD
    # Set a single attribute for a persistent object
    # required params
    #   :database  - the database to use, must be :world or :instance
    #   :persistence_id - id of the existing persistent object whose attribute is being set
    #   :name - Symbol - name of the attribute to set
    #   :value - value - value of the attribute to set - value must implement .to_json
    # @return nil
    def self.set_attribute params
      Storage::set_attribute params
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
    end

    # D in CRUD
    # No support to delete an object
    # No support to delete an attribute
    
    private
      
    @@class_map = Bijection.new
    @@class_map.add NoricMud::Object, "object"

    def self.object_class_type_to_string klass
      @class_map.get_y klass
    end

    def self.object_class_string_to_type string
      @class_map.get_x string
    end

    # Serialize the passed data into a String containing JSON.
    def self.serialize data
      { :data => data }.to_json
    end

    # Deserialize the passed String containing JSON, which must have been previously serialized with Persistence::serialize(). 
    def self.deserialize json_string
      JSON.parse(json_string)[:data]
    end 
  end
end
