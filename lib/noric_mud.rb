require "thread"

require_relative "noric_mud/object"
require_relative "noric_mud/persistence"

module NoricMud
  class << self

    # Determine the current room of an object.
    # Could be nil if object is detached.
    # Could be nil if the object is a zone or something without a Room as an ancestor
    def room
    end
    
    # Move the passed object of type NoricMud::Object from object.location to the passed destination
    # Updates the contents of the old and new locations
    # @return nil
    def move object, destination
      object.location.contents.delete object unless object.location.nil?
      object.location = destination
      destination.contents << object
      nil
    end

    @@queue = Queue.new

    # push block onto queue for asynchronous execution
    def async &block
      @@queue.push block if block_given?
      nil
    end

    def clear_async_queue
      @@queue.clear
      nil
    end

    def start_async_thread
      @@thread ||= Thread.new do
        while true
          block = @@queue.pop
          block.call
        end
      end
      nil
    end    
  end
end
