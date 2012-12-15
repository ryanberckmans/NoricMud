module NoricMud
  #TransientObjectError indicates an operation expected an object to be persistent, but it wasn't.
  class TransientObjectError < RuntimeError
    # @param object - the transient object which was expected to be persistent
    def initialize object
      @object = object
      super "expected a persistent object"
    end
    attr_reader :object
  end
end
