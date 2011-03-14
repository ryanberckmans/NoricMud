class Exit < ActiveRecord::Base
  NORTH = 0
  EAST = 1
  SOUTH = 2
  WEST = 3
  UP = 4
  DOWN = 5

  DIR_STRINGS = {
    NORTH => "north",
    EAST => "east",
    SOUTH => "south",
    WEST => "west",
    UP => "up",
    DOWN => "down",
  }

  belongs_to :room
  belongs_to :destination, :class_name => "Room"
  
  validates_presence_of :room_id, message:"Exit requires a room it's attached to."
  validates_presence_of :destination_id, message:"Exit requires a destination."
  
  
  validates_presence_of :direction, message:"Exit requires a direction."
  validates_numericality_of :direction, only_integer:true, greater_than_or_equal_to:NORTH, less_than_or_equal_to:DOWN, message:"Direction must be integer between Exit::NORTH and Exit::DOWN"
  validates_uniqueness_of :direction, :scope => :room_id, message:"Only one exit per direction in a room."

  def self.direction_to_s( dir )
    raise "expected to find dir in DIR_STRINGS" unless DIR_STRINGS.key? dir
    DIR_STRINGS[dir]
  end
end
