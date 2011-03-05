class Room < ActiveRecord::Base
  validates_presence_of :name

  attr_accessor :mobs

  after_initialize do |room|
    room.mobs = []
    Log::debug "loaded #{room.name}", "room"
  end
end


