class Account < ActiveRecord::Base
  has_many :characters
  has_many :mobs, :through => :characters
  validates_presence_of :name, :message => "An account name is required."
  validates_presence_of :password, :message => "An account password is required."
  validates_uniqueness_of :name, :case_sensitive => false, :message => "That account name is in use."
  validates_format_of :name, :with => /\A[[:alnum:]]+\z/, :message => "Account names may have letters and numbers only."
  validates_format_of :password, :with => /\A[[:alnum:]]+\z/, :message => "Account passwords may have letters and numbers only."
end