class Exit < ActiveRecord::Base
  NORTH = 0
  EAST = 1
  SOUTH = 2
  WEST = 3
  UP = 4
  DOWN = 5

  belongs_to :room
  validates_presence_of :room, message:"Exit requires a room it's attached to."
  validates_presence_of :direction, message:"Exit requires a direction."
  validates_numericality_of :direction, only_integer:true, greater_than_or_equal_to:NORTH, less_than_or_equal_to:DOWN, message:"Direction must be integer between Exit::NORTH and Exit::DOWN"
  validates_uniqueness_of :direction, :scope => :room_id, message:"Only one exit per direction in a room."
end
