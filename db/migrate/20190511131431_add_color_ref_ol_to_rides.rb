class AddColorRefOlToRides < ActiveRecord::Migration[5.1]
  def change
    add_column :rides, :pink_pref, :boolean
  end
end
