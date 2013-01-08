require_relative "object"
require_relative "persistence/storage"
require_relative "persistence/util"

module NoricMud
  module Persistence
    class << self
      def identity_map= identity_map
        @identity_map = identity_map
      end

      # R in CRUD
      # Get an object with the passed persistence_id from the db
      # @param [Symbol] database - the database to get from, must be :world or :instance
      # @param [Fixnum] persistence_id - id of the existing persistent object to get
      # @return NoricMud::Object with the passed persistence_id
      def get_object database, persistence_id
        @identity_map.get_object database, persistence_id
      end

      # C in CRUD
      # Create a new object in the database, returning its new persistence_id. The passed object will not be modified and must assign the returned persistence_id to itself
      # required params
      #   object - NoricMud::Object which will be created in the database, must not already be persistent
      # @return persistence_id of the newly created object
      def create_object object
        raise "object must be transient when calling create_object" if object.persistent?
        
        params = {
          :database => object.database,
          :location_persistence_id => object.location_persistence_id,
          :attributes => object.send(:attributes)
        }
        
        # Use the object class to create an attribute with (OBJECT_CLASS_MAGIC_ATTRIBUTE_NAME, string value of class), used to reconstruct the object
        object_class_string = object.class.to_s

        params[:attributes] ||= {}
        params[:attributes] = params[:attributes].merge({ Util::OBJECT_CLASS_MAGIC_ATTRIBUTE_NAME => object_class_string }) # merge creates a new hash; use a new hash to prevent modifications to passed attributes; the copy produced by merge is a shallow clone and could still result in unwanted mutations to the passed attributes

        params[:attributes].each_pair do |name,value|
          params[:attributes][name] = Util::serialize value
        end
        
        persistence_id = Storage::create_object params

        @identity_map.add_object persistence_id, object
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
      def set_attribute params
        params[:value] = Util::serialize params[:value]
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
      def set_location params
        Storage::set_location params
        nil
      end

      # D in CRUD
      # No support to delete an object
      # No support to delete an attribute
    end
  end
end
