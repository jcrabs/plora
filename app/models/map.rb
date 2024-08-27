class Map < ApplicationRecord
  belongs_to :user
  has_many :annotations
  has_many :segments
end
