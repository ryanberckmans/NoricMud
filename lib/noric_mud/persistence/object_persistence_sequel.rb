require 'yaml'
require 'sequel'

Sequel.extension :migration

module NoricMud
  module Persistence
    def self.migrate sequel_db
      Sequel::Migrator.run sequel_db, 'db/migrations', :use_transactions => true
      sequel_db
    end

    def self.connect_db yml_path
      config = YAML.load_file(yml_path)[ ENV['RAILS_ENV'] ]
      Sequel.connect( 
                     config['database'],
                     :max_connections => config['pool'],
                     :pool_timeout => config['timeout'],
                     :test => true
                     )
    end
    
    @@world_db    = migrate connect_db 'config/world_database.yml'
    @@instance_db = migrate connect_db 'config/instance_database.yml'

    # R in CRUD
    # Recursively loads from db the object subtree rooted at the passed object_id
    def self.load object_id
      #object_attributes = AttributeModel.find :object_id => object_id

      #object = nil# construct proper object using object_attributes

      #contained_object_models = ObjectModel.find :location_object_id => object_id # Object table has index on location_object_id

      #contained_object_models.each do |contained_object_model|
      #  object.contents << load contained_object_model.id
      #end

      #object
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
