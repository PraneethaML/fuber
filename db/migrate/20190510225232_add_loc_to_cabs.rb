class AddLocToCabs < ActiveRecord::Migration[5.1]
  def change
    add_column :cabs, :lat, :integer
    add_column :cabs, :long, :integer
  end
end
