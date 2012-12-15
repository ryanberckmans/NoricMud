require_relative 'transient_object_error'

module NoricMud
  # Instances of NoricMud::Object are not threadsafe and are intended to be used by a single thread.
  class Object

    # Constructor for NoricMud::Object
    # Any parameters will be set without any updates to persistence. This is intended for use, e.g. within persistence itself, to deserialize an object subtree from persistence without circularly writing back to persistence.
    # optional params
    #   :attributes - set of attributes for this object
    #   :location - an instance of NoricMud::Object to attach to
    #   :persistence_id - nil or FixNum if this object is persisted
    def initialize params={}
      raise "attributes must be a Hash" if params.key? :attributes && !params[:attributes].is_a?(Hash)
      validate_location params[:location]
      
      @attributes = params[:attributes] || {} # never modify directly, use set_attribute
      @location = params[:location] # never modify directly, use location=
      @persistence_id = params[:persistence_id]

      @contents = [] # transient. It's expected, but unenforced, that any NoricMud::Object with location set to this should be included in contents.
    end

    attr_reader :persistence_id, :location

    attr_accessor :contents

    def persistent?
      persistence_exists? || (!location.nil? && location.persistent?)
    end

    def location_persistence_id
      location.nil? ? nil : location.persistence_id
    end

    # Creates persistence for this object, unless it already exists
    # @return nil
    def persist
      unless persistence_exists?
        @persistence_id = Persistence::create_object :database => database, :class => self.class, :location_persistence_id => location_persistence_id, :attributes => @attributes
      end
      # note that contents depends on this persistence_id and this object must be saved first
      # once Persistence is asynchronous this will become trickier
      contents.each do |contained_object|
        # If the contained_object doesn't have persistence, we want to create it.
        # If the contained_object does have persistence, we want to make sure that any new persistence_id is set as the contained_object's location_persistence_id
        # This behavior is exactly what location= does, and so call it instead of persist() which wouldn't update location_persistence_id when persistence already exists.
        # The inefficiency with location= is that every child object creating a new persistence will have to call up to this object in persistent?.  That's ok for now.
        contained_object.location = self
      end
      nil
    end

    # Set this object's location. Note that location.contents should include this (and any former location.contents should exclude this), and this must be done externally.
    # If the new location is persistent, this object will be persisted.
    # @param new_location - NoricMud::Object to set as this object's location
    # @return nil
    def location= new_location
      validate_location new_location

      @location = new_location
      if persistence_exists?
        Persistence::set_location :database => database, :persistence_id => persistence_id, :location_persistence_id => location_persistence_id
      else
        persist if !new_location.nil? && new_location.persistent?
      end
      nil
    end

    def persistence_exists?
      !persistence_id.nil?
    end

    # Implements Marshal interface, http://www.ruby-doc.org/core-1.9.3/Marshal.html
    def _dump level
      raise TransientObjectError.new self unless persistence_exists?
      persistence_id.to_s
    end

    # Implements Marshal interface, http://www.ruby-doc.org/core-1.9.3/Marshal.html
    def self._load persistence_id_string
      Persistence::get_object :database => database, :persistence_id => persistence_id_string.to_i
    end

    # Override. Returns the persistence database for all instances of this class
    # @returns database - must be :world or :instance
    def self.database
      :instance
    end

    # Do not override. Convenience method to call Class.database
    def database
      self.class.database
    end

    protected
    # Get an attribute on this object.
    # @param name - Symbol - name of the attribute to get
    # @return attribute value for the passed name
    def get_attribute name
      @attributes[name]
    end
    
    # Set an attribute on this object.
    # @param name - Symbol - name of the attribute to set
    # @param value - value of the attribute to set - value must implement .to_json for persistence
    # @return nil
    def set_attribute name, value
      raise "attribute name must be a Symbol" unless name.is_a? Symbol # things can get pretty broken during persistence deserialization / object reconstruction if attribute name isn't a Symbol
      @attributes[name] = value
      if persistent?
        raise "an object that's persistent should have existing persistence in the database already, because we're in set_attribute(); this class isn't threadsafe and persistence should be created when persist() is called or location is set to a persistent location" unless persistence_exists?
        Persistence::set_attribute :database => database, :persistence_id => persistence_id, :name => name, :value => value
      end
      nil
    end

    # Set an attribute on this object, unless the attribute already exists
    # Same params as set_attribute
    # @return nil
    def set_attribute_unless_exists name, value
      set_attribute name, value unless @attributes.key? name
      nil
    end

    private
    def validate_location location
      raise "location must be an instance of NoricMud::Object or nil" if !(location.nil? || location.is_a?(NoricMud::Object))
    end

    def attributes
      @attributes
    end

    public
    def to_s
      s = ""
      s += "object, ruby object_id:#{self.object_id}\n"
      s += "  persistence_id: #{persistence_exists? ? persistence_id : nil}\n"
      s += "  persistent?: #{persistent?.to_s}\n"
      s += "  location persistence_id: #{location_persistence_id}\n"
      s += "  attributes: #{@attributes.to_s}\n"
      s += "  contents: #{contents.empty? ? "<empty>" : ""}\n\n"
      unless contents.empty?
        t = ""
        contents.each do |object|
          t += object.to_s
        end
        t.lines.each do |line|
          s += "    #{line}"
        end
      end
      s
    end
  end
end
