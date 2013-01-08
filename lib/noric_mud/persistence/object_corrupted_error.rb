module NoricMud
  # ObjectCorruptedError is raised when Persistence cannot interpret the stored data for an object and therefore cannot load the object
  class ObjectCorruptedError < RuntimeError
    # @param persistence_id - id of the object with corrupted data preventing a proper load
    def initialize persistence_id
      @persistence_id = persistence_id
      super "Object with persistence id #{persistence_id} could not be loaded"
    end
    attr_reader :persistence_id
  end
end
