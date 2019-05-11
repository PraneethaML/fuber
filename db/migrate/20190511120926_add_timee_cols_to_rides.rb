class AddTimeeColsToRides < ActiveRecord::Migration[5.1]
  def change
    add_column :rides, :ride_start_time, :timestamp
    add_column :rides, :ride_end_time, :timestamp
  end
end
