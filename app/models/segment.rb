class Segment < ApplicationRecord
  belongs_to :map
  has_many :points
  has_one_attached :gpx
end
