module NoricMud
  #TransientObjectError is raised when a transient object is required to be persistent.
  class TransientObjectError < RuntimeError
    # @param object - the transient object which was expected to be persistent
    def initialize object
      @object = object
      super "expected a persistent object"
    end
    attr_reader :object
  end
end
