class CreateCustomers < ActiveRecord::Migration[5.1]
  def change
    create_table :customers do |t|
      t.string :cab_id
      t.boolean :pink_preference
      t.integer :src_lat
      t.integer :src_long
      t.integer :dest_lat
      t.integer :dest_long

      t.timestamps
    end
  end
end
