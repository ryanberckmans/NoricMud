require 'yaml'
require 'sequel'

Sequel.extension :migration

module NoricMud
  module Persistence
    class SequelAdapter; end; # Declare SequelAdapter so we can assign it to Storage (and not have to do it below the class definition)

    Storage = SequelAdapter # Wire Persistence to use SequelAdapter as Storage
    
    class SequelAdapter
      class << self
        public

        # Return all attributes in a hash { :attribute_name => "<serialized json>" } for the passed object id.  Note that the attribute values are serialized JSON at this point.
        # required params
        #   :object_id - the primary key of the objects table whose attributes will be loaded
        #   :database  - the database to load from, must be :world or :instance
        def load_attributes params
          object_attributes = {}

          (get_db params[:database])[:attributes].where(:object_id => params[:object_id]).select(:name, :value).all do |row|
            object_attributes[row[:name].to_sym] = row[:value]
          end

          object_attributes
        end

        # Return the ids of all objects with the passed object_id as their location_object_id
        # required params
        #   :object_id - the primary key of the objects table whose attributes will be loaded
        #   :database  - the database to load from, must be :world or :instance
        def load_object_contents_ids params
          object_contents_ids = []
          
          (get_db params[:database])[:objects].where(:location_object_id => params[:object_id]).select(:id).all do |row|
            object_contents_ids << row[:id]
          end

          object_contents_ids
        end

        # Create a new object in the database
        # optional params
        #   :location_object_id - location_object_id for the new object
        #   :attributes - Hash of String name -> String value - attributes for the new object
        # @return object_id of the newly created object
        def create_object params
        end

        # Save a single attribute for a persistent object
        # required params
        #   :persistence_id - existing object id
        #   :name - String - name of the attribute to save
        #   :value - String - value of the attribute to save
        # @returns nil
        def save_attribute params
          nil
        end

        # Set the location_object_id for an existing object
        # required params
        #   :persistence_id - existing object id to set location for
        #   :location_persistence_id - existing object id which is the location to set
        # @returns nil
        def set_location params
          nil
        end
        
        private
        
        def migrate sequel_db
          Sequel::Migrator.run sequel_db, 'db/migrations', :use_transactions => true
          sequel_db
        end

        def connect_db yml_path
          config = YAML.load_file(yml_path)[ ENV['RAILS_ENV'] ]
          Sequel.connect( 
                         config['database'],
                         :max_connections => config['pool'],
                         :pool_timeout => config['timeout'],
                         :test => true
                         )
        end

        def get_db name
          @@databases[name]
        end
      end # class << self

      @@databases = {
        :world    => (migrate connect_db 'config/world_database.yml'),
        :instance => (migrate connect_db 'config/instance_database.yml')
      }

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
