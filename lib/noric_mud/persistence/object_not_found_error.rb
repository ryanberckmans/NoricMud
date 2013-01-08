module NoricMud
  # ObjectNotFoundError is raised when Persistence cannot find a requested object
  class ObjectNotFoundError < RuntimeError
    # @param persistence_id - id of the object that wasn't found
    def initialize persistence_id
      @persistence_id = persistence_id
      super "couldn't find an Object with persistence id #{persistence_id}"
    end
    attr_reader :persistence_id
  end
end
