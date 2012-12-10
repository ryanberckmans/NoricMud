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

    # instance variables
    #attributes
    
    # public operations
    #bool persist?
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
    
    def initialize persistence=nil
      @persistence = persistence
    end

    def persist?
      !@persistence.nil?
    end

    # if no persistence exists, create new persistence and save
    # postcondition: persist? == true
    def persist
      @persistence = persistence_class.new self unless persist?
      nil
    end

    protected

    # subclasses of MudObject override persistence_class
    # to return the persistence class associated with the subclass
    def persistence_class
      raise "#persistence_class must be overridden"
    end
  end
end
