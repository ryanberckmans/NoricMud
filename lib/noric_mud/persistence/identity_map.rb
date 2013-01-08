require_relative 'util'
require_relative 'object_not_found_error'
require_relative 'object_corrupted_error'
require_relative 'storage'

module NoricMud
  module Persistence
    # IdentityMap is a singleton which maintains references to all objects persisted in the database.
    # IdentityMap will load all database object upon construction.
    # The consumer is responsible for adding newly persisted objects to IdentityMap
    class IdentityMap
      DATABASES = [:world, :instance]

      def self.add_object object
        @@instance.add_object object
      end

      def self.get_object database, persistence_id
        @@instance.get_object database, persistence_id
      end

      private
      # TODO of course making initialize private won't work - need to make new private I think
      def initialize
        @all_objects = load_all_objects
      end

      def add_object object
        raise "expected object to have a persistence_id" if object.persistence_id.nil?
        raise "expected object to not be in the identity map" if @all_objects[object.database].key? object.persistence_id
        @all_objects[object.database][object.persistence_id] ||= object
        nil
      end

      def get_object database, persistence_id
        object = @all_objects[database][persistence_id]
        raise ObjectNotFoundError, persistence_id unless object
        object
      end
      
      def load_all_objects
        def create_object_from_serialized_attributes persistence_id, attributes
          raise ObjectCorruptedError, persistence_id unless attributes.key? Util::OBJECT_CLASS_MAGIC_ATTRIBUTE_NAME
          object_class = Util::constantize Util::deserialize attributes.delete Util::OBJECT_CLASS_MAGIC_ATTRIBUTE_NAME
          object_class.new :persistence_id => persistence_id
        end

        def setup_all_objects_contents all_objects, database
          all_objects.each_pair do |persistence_id,object|
            object_contents_ids = Storage::get_object_contents_ids :database => database, :persistence_id => persistence_id
            object_contents_ids.each do |contained_id|
              object.contents << all_objects[contained_id]
              all_objects[contained_id].send :unsafe_set_location, object
            end
          end
        end

        def setup_all_objects_attributes all_objects, all_serialized_attributes
          all_objects.each_pair do |persistence_id,object|
            object_attributes = {}
            all_serialized_attributes[persistence_id].each_pair do |name,serialized_value|
              object_attributes[name] = Util::deserialize serialized_value
            end
            object.send :unsafe_set_attributes, object_attributes
          end
        end

        def create_all_objects all_persistence_ids, all_serialized_attributes
          all_objects = {}
          corrupted_objects = []
          all_persistence_ids.each do |persistence_id|
            begin
              all_objects[persistence_id] = create_object_from_serialized_attributes persistence_id, all_serialized_attributes[persistence_id]
            rescue ObjectCorruptedError
              corrupted_objects << persistence_id
              all_serialized_attributes.delete persistence_id
              # TODO log object ids which cannot be loaded
              # puts "[persistence.load_all_objects] discarding corrupted object with id #{persistence_id}"
            end
          end
          all_persistence_ids -= corrupted_objects
          all_objects
        end

        def load_all_serialized_attributes all_persistence_ids, database
          all_serialized_attributes = {}
          all_persistence_ids.each do |persistence_id|
            all_serialized_attributes[persistence_id] = Storage::get_attributes :database => database, :persistence_id => persistence_id
          end
          all_serialized_attributes
        end

        def load_all_objects_from_database database
          all_persistence_ids = Storage::get_all_object_ids :database => database
          all_serialized_attributes = load_all_serialized_attributes all_persistence_ids, database
          all_objects = create_all_objects all_persistence_ids, all_serialized_attributes
          setup_all_objects_contents all_objects, database
          setup_all_objects_attributes all_objects, all_serialized_attributes
          all_objects
        end

        all_objects = {}
        DATABASES.each { |db| all_objects[db] = load_all_objects_from_database db }
        all_objects
      end # load_all_objects

      raise "expected IdentityMap singleton instance to not exist yet" if defined? @@instance
      @@instance = IdentityMap.new
    end
  end
end
