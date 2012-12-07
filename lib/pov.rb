require 'continuation'
require 'ostruct'

# This API is suitable for sending different points of view to a set of observers,
# if the points of view follow this pattern: "specific, less specific, .., everybody else"
# E.g. in a MUD, most points of view are patterned as "me, you, everybody else"

# Example 1
#
# Bob says 'Hi'
#
# pov_scope do  # pov_scope wraps each invocation of the pov system
#   pov(bob) { "You say, 'Hi'." }  # Declare Bob's point of view
#   pov(bob.room.mobs) { "Bob says, 'Hi'." } # Declare the room's point of view.  Note that, although Bob himself is included in bob.room.mobs, pov_scope prevents Bob from seeing two points of view.
# end

# Example 2
#
# Fred disconnects from the game.
#
# pov_scope do
#   pov_none fred # Fred gets no point of view, because he disconnected
#   pov(fred.room.mobs) { "Fred disconnects." }
# end

# Example 3
#
# Sally is in a furious melee, and hits Bob and Fred with the dual-slash ability. Jim is blinded and sees nothing.
#
# pov_scope do
#   pov_none jim # Jim is blinded and sees nothing
#   pov(sally) { "You hit Bob and Fred with dual-slash!" }
#   pov(bob, fred) { "Sally hits you with dual-slash!" } # pov accepts a list of arguments, or a list of lists, or anything that ruby can Array.flatten
#   pov(sally.room.mobs) { "Sally hits Bob and Fred with dual-slash!" }
# end

# HUGE TERRIBLE HACK - use a global variable for the CURRENT_POV_SCOPE
#
# The old pov.rb used continuations which aren't supported in JRuby.
# It's impossible to maintain the original pov syntax without continuations:
#  (i) you can have the original syntax, but must use instance_eval around the block,
#      which makes stuff like pov(bob) { @game.send } break, because @game isn't an instance variable of PointOfViewScope
#  (ii) TODO: update the syntax to pov_scope do |pov| pov.pov; pov.none; end
#  (iii) find some cleverer way :(

# Start a new pov_scope. The mandatory passed block accumulates points of view using pov() and pov_none()
def pov_scope &block
  raise "pov_scope requires a block" unless block_given?
  scope = PointOfViewScope.new
  Thread.current[:current_pov_scope] = scope  # HACK!
  block.call
  scope.send $POV_send_func
  nil
end

def pov *observers, &block
  Thread.current[:current_pov_scope].pov *observers, &block # HACK!
end

def pov_none *observers, &block
  Thread.current[:current_pov_scope].pov_none *observers, &block # HACK!
end

# Dangerous. The lambda send_func( observer, msg) is set as the global function used in pov_scope()
def pov_send send_func
  $POV_send_func = send_func
end

$POV_send_func = ->(key,value){ puts key + " pov << " + value  }

# Do not instantiate directly. Accumulates observers' points of view for the current pov_scope.
# A PointOfViewScope is instantiated for each pov_scope()
class PointOfViewScope
  def initialize
    @points_of_view = {}
  end

  # Send the accumulated points of view using the passed lambda send_func( observer, msg )
  #
  # Do not call directly. Used by pov_scope().
  def send send_func
    @points_of_view.each_pair do |key,value|
      send_func[key,value]
    end
    nil
  end

  # Declare the passed observers as having the point of view returned by calling the passed block, in the current scope
  # Observers already having a point of view in the current scope are skipped.
  #
  # Call the passed block at most once, if the list of observers is non-empty.
  def pov *observers
    raise "pov requires a block" unless block_given?
    flattened_observers = observers.flatten
    return if flattened_observers.empty?
    pov_msg = yield
    flattened_observers.each do |observer|
      @points_of_view[observer] = pov_msg unless @points_of_view.key? observer
    end
    nil
  end

  # Declare the passed observers as having no point of view (i.e. the empty string), in the current scope
  def pov_none *observers
    pov(*observers) { "" }
  end
end
