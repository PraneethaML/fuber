class CreateCabs < ActiveRecord::Migration[5.1]
  def change
    create_table :cabs do |t|

      t.timestamps
    end
  end
end
