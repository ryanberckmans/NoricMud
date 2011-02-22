class Account < ActiveRecord::Base
  has_many :characters
  has_many :mobs, :through => :characters
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_format_of :name, :with => /\A[[:alnum:]]+\z/, :message => "Only alphanumeric characters allowed"
end
