require "abbrev_map.rb"

class Exit < ActiveRecord::Base
  NORTH = 0
  EAST = 1
  SOUTH = 2
  WEST = 3
  UP = 4
  DOWN = 5

  REVERSE_DIRECTION = {
    NORTH => SOUTH,
    SOUTH => NORTH,
    EAST => WEST,
    WEST => EAST,
    UP => DOWN,
    DOWN => UP,
  }

  DIRECTION_I_TO_S = {
    NORTH => "north",
    EAST => "east",
    SOUTH => "south",
    WEST => "west",
    UP => "up",
    DOWN => "down",
  }

  DIRECTION_S_TO_I = {
    "north" => NORTH,
    "east" => EAST,
    "south" => SOUTH,
    "west" => WEST,
    "up" => UP,
    "down" => DOWN,
  }
  
  
  @@directions = AbbrevMap.new
  DIRECTION_S_TO_I.each_pair do |dir_string,dir_int|
    @@directions.add dir_string, dir_int
  end

  def self.i_to_s( dir_int )
    DIRECTION_I_TO_S[dir_int]
  end

  def self.s_to_i( dir_string, abbreviation = true )
    if abbreviation
      res = @@directions.find dir_string
      return nil unless res
      res[:value]
    else
      DIRECTION_S_TO_I[dir_string]
    end
  end

  def self.reverse( dir )
    if dir.kind_of? Fixnum
      REVERSE_DIRECTION[dir]
    else
      i_to_s(REVERSE_DIRECTION[s_to_i dir])
    end
  end

  def self.create_exit( from, to, dir )
    exit = Exit.create({ :room => from, :direction => dir, :destination => to })
    raise "Failed to create exit from #{from.to_s} to #{to.to_s} direction #{dir.to_s}" if exit.new_record?
    from.exit[dir] = exit
    from.exits true
  end

  belongs_to :room
  belongs_to :destination, :class_name => "Room"
  
  validates_presence_of :room_id, message:"Exit requires a room it's attached to."
  validates_presence_of :destination_id, message:"Exit requires a destination."
  
  
  validates_presence_of :direction, message:"Exit requires a direction."
  validates_numericality_of :direction, only_integer:true, greater_than_or_equal_to:NORTH, less_than_or_equal_to:DOWN, message:"Direction must be integer between Exit::NORTH and Exit::DOWN"
  validates_uniqueness_of :direction, :scope => :room_id, message:"Only one exit per direction in a room."
end
