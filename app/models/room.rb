class Room < ActiveRecord::Base
  has_many :exits
  
  validates_presence_of :name

  attr_accessor :mobs, :north, :east, :south, :west, :up, :down, :exit

  after_initialize :on_load

  def has_exit?( dir )
    self.exit[dir]
  end

  def delete_exit( dir )
    raise "expected to have exit #{Exit.i_to_s dir}" unless has_exit? dir
    xit = self.exit[dir]
    self.exit.delete dir
    xit.destroy
  end
  
  def on_load
    self.mobs = []
    self.exit = {}
    self.exits.each { |xit| self.exit[xit.direction] = xit }
  end
end


