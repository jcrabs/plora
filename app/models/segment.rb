class Segment < ApplicationRecord
  belongs_to :map
  has_many :points, dependent: :destroy
  has_one_attached :gpx
  attr_accessor :mode
end
