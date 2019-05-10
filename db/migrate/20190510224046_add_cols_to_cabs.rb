class AddColsToCabs < ActiveRecord::Migration[5.1]
  def change
    add_column :cabs, :cust_id, :string
    add_column :cabs, :is_pink, :boolean
    add_column :cabs, :is_available, :boolean
  end
end
