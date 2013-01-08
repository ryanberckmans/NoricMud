module NoricMud
  module Persistence
    # Persistence::Storage points to the current storage engine
    # Swapping storage engines should require changing only these two lines
    require_relative "sequel_adapter"
    Storage = SequelAdapter
  end
end
