class AddSafeToRooms < ActiveRecord::Migration
  def change
    add_column :rooms, :safe, :boolean, :default => false
  end
end
