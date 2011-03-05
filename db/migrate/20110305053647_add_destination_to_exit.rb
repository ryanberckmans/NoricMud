class AddDestinationToExit < ActiveRecord::Migration
  def self.up
    add_column :exits, :destination_id, :integer
  end

  def self.down
    remove_column :exits, :destination_id
  end
end
