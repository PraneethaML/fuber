class CreateRides < ActiveRecord::Migration[5.1]
  def change
    create_table :rides do |t|
      t.integer :fare
      t.references :cab, foreign_key: true
      t.references :customer, foreign_key: true

      t.timestamps
    end
  end
end
