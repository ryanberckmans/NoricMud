require 'yaml'
require 'sequel'

Sequel.extension :migration

module NoricMud
  module Persistence
    class Sequel
      class << self
        public
        def world_load_attributes object_id
          load_attributes object_id, @@world_db
        end

        def instance_load_attributes object_id
          load_attributes object_id, @@instance_db
        end

        private
        def self.migrate sequel_db
          Sequel::Migrator.run sequel_db, 'db/migrations', :use_transactions => true
          sequel_db
        end

        private
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

        # Return all attributes in a hash { :attribute_name => "<serialized json>" } for the passed object id.  Note that the attribute values are serialized JSON at this point.
        def self.load_attributes object_id, sequel_database
          object_attributes_dataset = sequel_database[:attributes].where(:object_id => object_id).select(:name, :value).all

          object_attributes = {}
          object_attributes_dataset.each do |object_attribute|
            object_attributes[object_attribute[:name].to_sym] = object_attribute[:value]
          end

          object_attributes
        end

        # Each persisted Object has exactly one ObjectPersistence
        class TODO_CHANGE_ME_ObjectPersistence

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
  end
end
