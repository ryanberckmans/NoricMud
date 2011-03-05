class CreateExits < ActiveRecord::Migration
  def self.up
    create_table :exits do |t|
      t.integer :room_id
      t.integer :direction

      t.timestamps
    end
  end

  def self.down
    drop_table :exits
  end
end
