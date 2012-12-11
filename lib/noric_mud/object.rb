module NoricMud
  class Object
    # db columns on all mud objects:
    #parent_mud_object_id # i.e. location.persistence_id
    
    # db attributes on all mud objects:
    #short_name
    #long_name
    #description
    #keywords

    # transient attributes on all mud objects:
    #contents

    # public operations
    #bool persistent?
    #void persist
    #id persistence_id
    #location=
    #location
    #short_name=
    #short_name
    #long_name=
    #long_name
    #description=
    #description
    #[string] keywords
    #add_keyword
    #remove_keyword

    # private operations
    #void set_attribute attribute_name, attribute_value
    #void persist_attribute attribute_name, attribute_value
    #void create_new_persistence
    #bool persistence_exists?

    # overridden operations
    #bool persisted_attribute? attribute_name
    #klass perssitence_class

    # Constructor for NoricMud::Object
    # Any parameters will be set without any updates to persistence. This is intended for use, e.g. within persistence itself, to deserialize an object subtree from persistence without circularly writing back to persistence.
    # optional params
    #   :attributes - set of attributes for this object
    #   :location - an instance of NoricMud::Object to attach to
    #   :persistence_id - nil or FixNum if this object is persisted
    def initialize params={}
      @attributes = params[:attributes] || {} # never modify directly, use set_attribute
      @location = params[:location] # never modify directly, use location=
      @persistence_id = params[:persistence_id] # constant

      @contents = [] # transient. It's expected, but unenforced, that any NoricMud::Object with location set to this should be included in contents.
    end

    attr_reader :persistence_id, :location

    attr_accessor :contents

    def persistent?
      !persistence_id.nil? || (!location.nil? && location.persistent?)
    end

    def persist
    end

    def location= new_location
      #TODO
    end

    def to_s
      s = ""
      s += "object, ruby object_id:#{self.object_id}\n"
      s += "  persistence_id: #{persistence_id.nil? ? nil : persistence_id}\n"
      s += "  persistent?: #{persistent?.to_s}\n"
      s += "  location persistence_id: #{location.nil? ? nil : location.persistence_id}\n"
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
