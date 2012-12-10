module NoricMud
  module Persistence
    # Storage is responsible for wiring in the Persistence storage engine
    # Persistence::Storage is setup here and points to the current storage engine

    # Swapping storage engines should require changing only these two lines
    require_relative "sequel_adapter"
    Storage = SequelAdapter
  end
end
