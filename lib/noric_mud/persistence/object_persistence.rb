# require_relative "activerecord/object_model.rb"

module NoricMud
  module Persistence

    # R in CRUD
    # Recursively loads from db the object subtree rooted at the passed object_id
    def self.load object_id
      object_attributes = AttributeModel.find :object_id => object_id

      object = nil# construct proper object using object_attributes

      contained_object_models = ObjectModel.find :location_object_id => object_id # Object table has index on location_object_id

      contained_object_models.each do |contained_object_model|
        object.contents << load contained_object_model.id
      end

      object
    end

    # Each persisted Object has exactly one ObjectPersistence
    class ObjectPersistence

      # C in CRUD
      # Construct an ObjectPersistence used to persist a single Object
      # Any children of the Object are persisted separately
      def initialize object_to_persist
      end

      public
      def location_object_id=
      end
      
      def save_attribute attribute_name, attribute_value
      end

    end
  end
end
