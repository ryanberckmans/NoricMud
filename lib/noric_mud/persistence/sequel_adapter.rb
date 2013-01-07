require 'yaml'
require 'sequel'

Sequel.extension :migration

module NoricMud
  module Persistence
    class SequelAdapter
      class << self

        # Return persistence_ids for all objects in the database
        # required params
        #   :database - the database to get from, must be :world or :instance
        # @return an array of persistence_ids for all stored objects
        def get_all_object_ids params
          object_ids = nil

          sequel_db = get_db params[:database]
          sequel_db.transaction do
            object_ids = sequel_db[:objects].select_map(:id)
          end
          object_ids
        end

        # Return all attributes for the passed persistence id.
        # Attribute names are converted to symbols, e.g. "age" -> :age
        # Attribute values are unmodified (and, if applicable, not yet deserialized)
        #
        # required params
        #   :database  - the database to get from, must be :world or :instance
        #   :persistence_id - id for the object whose attributes will be returned
        # @return a hash of attributes { :attribute_name => String value } for the passed persistence_id
        def get_attributes params
          attributes = {}

          sequel_db = get_db params[:database]
          sequel_db.transaction do
            sequel_db[:attributes].where(:object_id => params[:persistence_id]).select(:name, :value).all do |row|
              attributes[row[:name].to_sym] = row[:value] # convert name to Symbol because it was convered into a String for storage
            end
          end

          attributes
        end

        # Return the persistence_ids for all objects contained by the object with the passed persistence_id
        # required params
        #   :database  - the database to get from, must be :world or :instance
        #   :persistence_id - id for the object whose contained ids will be returned
        # @return an array of persistence_ids for all contained by object with the passed persistence_id
        def get_object_contents_ids params
          object_contents_ids = nil

          sequel_db = get_db params[:database]
          sequel_db.transaction do
            object_contents_ids = sequel_db[:objects].where(:location_object_id => params[:persistence_id]).select_map(:id)
          end

          object_contents_ids
        end

        # Create a new object in the database
        # required params
        #   :database  - the database create in, must be :world or :instance
        # optional params
        #   :location_persistence_id - set as the location containing the new object
        #   :attributes - { Symbol name -> String value } - attributes for the new object
        # @return persistence_id of the newly created object
        def create_object params
          created_object_id = nil

          sequel_db = get_db params[:database]
          sequel_db.transaction do
            created_object_id = sequel_db[:objects].insert :location_object_id => params[:location_persistence_id]

            if params.key? :attributes
              # attributes input format:  { :gender => "SomeValue", :pet_name => "Fred", .., name_N => value_N }
              # format required by Sequel::Dataset::import:  [[created_object_id,"gender","SomeValue"], [created_object_id,"pet_name","Fred"], .., [created_object_id,name_N.to_s,value_N]]
              attributes_import_format = []
              params[:attributes].each_pair do |name,value|
                attributes_import_format << [created_object_id, name.to_s, value] # convert name to String as Symbol breaks sqlite
              end
              sequel_db[:attributes].import [:object_id,:name,:value], attributes_import_format
            end
          end

          created_object_id
        end

        # Set a single attribute for a persistent object
        # required params
        #   :database  - the database to use, must be :world or :instance
        #   :persistence_id - existing object id whose attribute is being set
        #   :name - Symbol - name of the attribute to set
        #   :value - String - value of the attribute to set
        # @return nil
        def set_attribute params
          sequel_db = get_db params[:database]
          sequel_db.transaction do
            attribute_record = sequel_db[:attributes].where( :object_id => params[:persistence_id], :name => params[:name].to_s ) # convert name to String as Symbol breaks sqlite

            if attribute_record.empty?
              # If the attribute doesn't exist, we must INSERT and not UPDATE
              attribute_record.insert :object_id => params[:persistence_id], :name => params[:name].to_s, :value => params[:value] # convert name to String as Symbol breaks sqlite
            else
              attribute_record.update :value => params[:value]
            end
          end
          nil
        end

        # Set the location_persistence_id for an existing object
        # required params
        #   :database  - the database to use, must be :world or :instance
        #   :persistence_id - existing object id to set location for
        #   :location_persistence_id - existing object id which is the location to set
        # @return nil
        def set_location params
          sequel_db = get_db params[:database]
          sequel_db.transaction do
            object_record = sequel_db[:objects].where( :id => params[:persistence_id] )
            raise "persistence_id must correspond to an existing object" if object_record.empty?
            object_record.update :location_object_id => params[:location_persistence_id]
          end
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
