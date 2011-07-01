class Character < ActiveRecord::Base
  belongs_to :account
  belongs_to :mob, :autosave => true
  validates_associated :mob, :message => "The mob associated with this character is invalid."
  validates_associated :account, :message => "The account associated with this character is invalid."
  validates_presence_of :mob, :message => "This character is not associated with a mob."
  validates_presence_of :account, :message => "This character is not associated with an account."
  validates_uniqueness_of :name, :case_sensitive => false, :message => "That character name is in use."
  validates_presence_of :name, :message => "A character name is required."
  validates_format_of :name, :with => /\A[[:alpha:]]+\z/, :message => "Character names may have letters only."

  include Seh::EventTarget
  attr_accessor :parents
end
