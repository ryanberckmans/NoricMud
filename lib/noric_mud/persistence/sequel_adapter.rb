require 'yaml'
require 'sequel'

Sequel.extension :migration

module NoricMud
  module Persistence
    class SequelAdapter
      class << self

        # Return all attributes for the passed persistence id.
        # Attribute names are converted to symbols, e.g. "age" -> :age
        # Attribute values are unmodified (and, if applicable, not yet deserialized)
        #
        # required params
        #   :persistence_id - id for the object whose attributes will be returned
        #   :database  - the database to get from, must be :world or :instance
        # @return a hash of attributes { :attribute_name => value } for the passed object id.  Note that the attribute values are serialized JSON at this poin.t
        def get_attributes params
          attributes = {}

          (get_db params[:database])[:attributes].where(:object_id => params[:persistence_id]).select(:name, :value).all do |row|
            attributes[row[:name].to_sym] = row[:value]
          end

          attributes
        end

        # Return the persistence_ids for all objects contained by the object with the passed persistence_id
        # required params
        #   :persistence_id - id for the object whose contained ids will be returned
        #   :database  - the database to get from, must be :world or :instance
        # @return an array of persistence_ids for all contained by object with the passed persistence_id
        def get_object_contents_ids params
          object_contents_ids = []
          
          (get_db params[:database])[:objects].where(:location_object_id => params[:persistence_id]).select(:id).all do |row|
            object_contents_ids << row[:id]
          end

          object_contents_ids
        end

        # Create a new object in the database
        # required params
        #   :database  - the database create in, must be :world or :instance
        # optional params
        #   :location_persistence_id - set as location_object_id for the new object
        #   :attributes - { String name -> String value } - attributes for the new object
        # @return object_id of the newly created object
        def create_object params
          created_object_id = (get_db params[:database])[:objects].insert :location_object_id => params[:location_persistence_id]

          if params.key? :attributes
            # attributes input format:  { :gender => :male, :pet_name => "Fred", .., name_N => value_N }
            # format required by Sequel::Dataset::import:  [[created_object_id, :gender,:male], [created_object_id, pet_name,"Fred"], .., [created_object_id, name_N,value_N]]
            attributes_import_format = []
            params[:attributes].each_pair do |name,value|
              attributes_import_format << [created_object_id, name, value]
            end
            (get_db params[:database])[:attributes].import [:object_id,:name,:value], attributes_db_format
          end

          created_object_id
        end

        # Save a single attribute for a persistent object
        # required params
        #   :database  - the database to use, must be :world or :instance
        #   :persistence_id - existing object id whose attribute is being set
        #   :name - String - name of the attribute to set
        #   :value - String - value of the attribute to set
        # @returns nil
        def set_attribute params
          (get_db params[:database])[:attributes].where( :object_id => params[:persistence_id], :name => params[:name] ).update :value => params[:value]
          nil
        end

        # Set the location_object_id for an existing object
        # required params
        #   :database  - the database to use, must be :world or :instance
        #   :persistence_id - existing object id to set location for
        #   :location_persistence_id - existing object id which is the location to set
        # @returns nil
        def set_location params
          (get_db params[:database])[:objects].where( :id => params[:persistence_id] ).update :location_object_id => params[:location_persistence_id]
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
    end
  end
end
