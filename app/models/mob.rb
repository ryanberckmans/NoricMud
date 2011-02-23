class Mob < ActiveRecord::Base
  validates_presence_of :short_name, :long_name

  attr_accessor :room, :char
end
