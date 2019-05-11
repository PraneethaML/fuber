class Ride < ApplicationRecord
  belongs_to :cab
  belongs_to :customer
end
