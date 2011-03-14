class Room < ActiveRecord::Base
  has_many :exits
  
  validates_presence_of :name

  attr_accessor :mobs, :north, :east, :south, :west, :up, :down, :exit

  after_initialize :on_load

  def has_exit?( dir )
    exits.each do |exit|
      return true if exit.direction == dir
    end
    false
  end
  
  def on_load
    self.mobs = []
    self.exit = {}
    self.exits.each { |xit| self.exit[xit.direction] = xit }
  end
end


