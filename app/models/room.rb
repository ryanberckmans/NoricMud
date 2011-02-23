class Room < ActiveRecord::Base
  validates_presence_of :name

  attr_accessor :mobs
end
