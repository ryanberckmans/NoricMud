class AddAccountAndMobToCharacter < ActiveRecord::Migration
  def self.up
    add_column :characters, :account_id, :integer
    add_column :characters, :mob_id, :integer
  end

  def self.down
    remove_column :characters, :mob_id
    remove_column :characters, :account_id
  end
end
