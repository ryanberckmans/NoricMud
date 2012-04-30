class CreatePersistedMobs < ActiveRecord::Migration
  def up
    create_table :persisted_mobs do |t|
      t.string :short_name
      t.string :long_name
      t.timestamps
    end
  end

  def down
    drop_table :persisted_mobs
  end
end
