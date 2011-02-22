class AddNameToCharacter < ActiveRecord::Migration
  def self.up
    add_column :characters, :name, :string
  end

  def self.down
    remove_column :characters, :name
  end
end
