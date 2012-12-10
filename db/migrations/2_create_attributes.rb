Sequel.migration do
  up do
    create_table(:attributes) do
      foreign_key :object_id, :objects, :on_delete => :cascade, :on_update => :cascade
      String :name, :null => false
      primary_key [:object_id, :name]
      index :object_id
      String :value, :text => true, :null => false
      check { length(name) > 0 }
      check { length(value) > 0 }
    end
  end
  down do
    drop_table :attributes
  end
end
