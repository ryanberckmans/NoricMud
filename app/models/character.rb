class Character < ActiveRecord::Base
  belongs_to :account
  belongs_to :mob
  validates_associated :mob, :account
  validates_uniqueness_of :name
  validates_presence_of :name
  validates_format_of :name, :with => /\A[[:alpha:]]+\z/, :message => "Only letters allowed"
end
