Sequel.migration do
  up do
    create_table(:objects) do
      primary_key :id
      Integer :location_object_id, :null => true, :index => true
      foreign_key [:location_object_id], :objects, :on_delete => :set_null, :on_update => :cascade
    end
  end
  down do
    drop_table :objects
  end
end
