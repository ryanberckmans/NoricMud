class AddPasswordToAccount < ActiveRecord::Migration
  def self.up
    add_column :accounts, :password, :string
    accounts = Account.find :all
    accounts.each do |account|
      account.password = "password" unless account.password
      raise unless account.save
    end
  end

  def self.down
    remove_column :accounts, :password
  end
end
