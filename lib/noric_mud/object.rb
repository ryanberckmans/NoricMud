module NoricMud
  # Instances of NoricMud::Object are not threadsafe and are intended to be used by a single thread.
  class Object
    # public operations
    #short_name=
    #short_name
    #long_name=
    #long_name
    #description=
    #description
    #[string] keywords
    #add_keyword
    #remove_keyword

    # Constructor for NoricMud::Object
    # Any parameters will be set without any updates to persistence. This is intended for use, e.g. within persistence itself, to deserialize an object subtree from persistence without circularly writing back to persistence.
    # optional params
    #   :attributes - set of attributes for this object
    #   :location - an instance of NoricMud::Object to attach to
    #   :persistence_id - nil or FixNum if this object is persisted
    def initialize params={}
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
      database = :world # TODO inject database, probably based on self.class
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
      @location = new_location
      if persistence_exists?
        database = :world # TODO inject database, probably based on self.class
        Persistence::set_location :database => database, :persistence_id => persistence_id, :location_persistence_id => location_persistence_id
      else
        persist if !new_location.nil? && new_location.persistent?
      end
      nil
    end

    def persistence_exists?
      !@persistence_id.nil?
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
        database = :world # TODO inject database, probably based on self.class
        Persistence::set_attribute :database => database, :persistence_id => persistence_id, :name => name, :value => value
      end
      nil
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
