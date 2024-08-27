class Segment < ApplicationRecord
  belongs_to :map
  has_many :points
end
