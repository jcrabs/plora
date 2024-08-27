class ExploredPointOfInterest < ApplicationRecord
  belongs_to :user
  belongs_to :point_of_interest
end
