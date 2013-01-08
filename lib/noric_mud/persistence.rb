require 'json'
require_relative "../util"
require_relative "object"
require_relative "persistence/storage"
require_relative "persistence/object_not_found_error"
require_relative "persistence/object_corrupted_error"

module NoricMud
  module Persistence

    OBJECT_CLASS_MAGIC_ATTRIBUTE_NAME = :__reserved__object_class # serialized objects set this attribute containing their class name, for construction during deserialization. The attribute name mustn't conflict with any existing attributes.

    public
    
    # R in CRUD
    # Get an object with the passed persistence_id from the db
    # required params
    #   :database  - the database to get from, must be :world or :instance
    #   :persistence_id - id of the existing persistent object to get
    # @return NoricMud::Object with the passed persistence_id
    def self.get_object params
      object = IDENTITY_MAP[params[:database]][params[:persistence_id]]
      raise ObjectNotFoundError, params[:persistence_id] unless object
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
      
      persistence_id = Storage::create_object params

      IDENTITY_MAP[persistence_id] = object
      persistence_id
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

    IDENTITY_MAP = {}
    def self.load_all_objects
      raise "load_all_objects may only be called once" unless IDENTITY_MAP.empty?
      
      def self.create_object_from_serialized_attributes persistence_id, attributes
        raise ObjectCorruptedError, persistence_id unless attributes.key? OBJECT_CLASS_MAGIC_ATTRIBUTE_NAME
        object_class = Util::constantize deserialize attributes.delete OBJECT_CLASS_MAGIC_ATTRIBUTE_NAME
        object_class.new :persistence_id => persistence_id
      end

      def self.setup_object_contents persistence_id, database, objects
        object_contents_ids = Storage::get_object_contents_ids :database => database, :persistence_id => persistence_id
        object_contents_ids.each do |contained_id|
          objects[persistence_id].contents << objects[contained_id]
          objects[contained_id].send :unsafe_set_location, objects[persistence_id]
        end
      end

      def self.load_all_objects_from_database database
        all_persistence_ids = Storage::get_all_object_ids :database => database

        serialized_attributes = {}
        objects = {}

        corrupted_objects = []
        all_persistence_ids.each do |persistence_id|
          serialized_attributes[persistence_id] = Storage::get_attributes :database => database, :persistence_id => persistence_id
          begin
            objects[persistence_id] = create_object_from_serialized_attributes persistence_id, serialized_attributes[persistence_id]
          rescue ObjectCorruptedError
            # TODO log object ids which cannot be loaded
            corrupted_objects << persistence_id
            serialized_attributes.delete persistence_id
          end
        end

        all_persistence_ids -= corrupted_objects

        all_persistence_ids.each { |persistence_id| setup_object_contents persistence_id, database, objects }

        all_persistence_ids.each do |persistence_id|
          object_attributes = {}
          serialized_attributes[persistence_id].each_pair do |name,serialized_value|
            object_attributes[name] = deserialize serialized_value
          end
          objects[persistence_id].send :unsafe_set_attributes, object_attributes
        end
        objects
      end

      [:world,:instance].each do |db|
        IDENTITY_MAP[db] = load_all_objects_from_database db
      end
    end

    # Serialize the passed data
    def self.serialize data
      Marshal.dump data
    end

    # Deserialize the passed serialized data
    def self.deserialize data
      Marshal.load data
    end

    load_all_objects
  end
end
