class AddQuitToRooms < ActiveRecord::Migration
  def change
    add_column :rooms, :quit, :boolean, :default => "false"
  end
end
