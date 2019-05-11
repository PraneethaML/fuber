class AddDistanceTravelledColToRides < ActiveRecord::Migration[5.1]
  def change
    add_column :rides, :dist_travelled, :integer
  end
end
