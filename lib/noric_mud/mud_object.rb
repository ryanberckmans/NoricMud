module NoricMud
  class MudObject
    def initialize persistence=nil
      @persistence = persistence
    end

    # asynchronously save this MudObject, if persistence exists
    def save
      @persistence.async_save self if @persistence
      nil
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
