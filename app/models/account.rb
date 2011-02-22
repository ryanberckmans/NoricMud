class Account < ActiveRecord::Base
  has_many :characters
  has_many :mobs, :through => :characters
  validates_presence_of :name, :message => "Account name is required."
  validates_uniqueness_of :name, :message => "Account name in use."
  validates_format_of :name, :with => /\A[[:alnum:]]+\z/, :message => "Account name may have only letters and numbers."
end
