class Room < ActiveRecord::Base
  validates_presence_of :name

  attr_accessor :mobs

  after_initialize :on_load

  def on_load
    self.mobs = []
    Log::debug "loaded #{name}", "room"
  end
end


