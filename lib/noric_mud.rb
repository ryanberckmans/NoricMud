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
