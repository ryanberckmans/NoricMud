require 'ref'

module NoricMud
  module Persistence
    # IdentityMap is a key,value Hash which has weak references to its values.
    # Ruby's garbage collector will reclaim objects if the only reference to them
    # is an IdentityMap value.
    class IdentityMap
      def initialize
        @soft_value_map = Ref::WeakValueMap.new
      end

      # Sets the passed key and value, replacing any previous value
      # @param key - key to associate with the passed value
      # @param value - value referenced by the passed key, will be garbage-collected if this is its only reference
      # @return nil
      def set_object key, value
        @soft_value_map[key] = value
        nil
      end

      # Returns the value associated with the passed key
      # May return nil if the key isn't in the IdentityMap, or if the value was garbage-collected
      # @return value
      def get_object key
        @soft_value_map[key]
      end
    end
  end
end
