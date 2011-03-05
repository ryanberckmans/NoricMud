class Room < ActiveRecord::Base
  has_many :exits
  
  validates_presence_of :name

  attr_accessor :mobs, :north, :east, :south, :west, :up, :down

  after_initialize :on_load

  def on_load
    self.mobs = []
    self.exits.each do |exit|
      if exit.direction == Exit::NORTH
        raise if self.north
        self.north = exit
      elsif exit.direction == Exit::EAST
        raise if self.east
        self.east = exit
      elsif exit.direction == Exit::SOUTH
        raise if self.south
        self.south = exit
      elsif exit.direction == Exit::WEST
        raise if self.west
        self.west = exit
      elsif exit.direction == Exit::UP
        raise if self.up
        self.up = exit
      elsif exit.direction == Exit::DOWN
        raise if self.down
        self.down = exit
      else
        raise "not an exit type"
      end
    end
  end
end


