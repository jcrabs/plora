class Map < ApplicationRecord
  belongs_to :user
  has_many :annotations
  has_many :segments

  validates :description, length: { maximum: 30, message: "Description should not exceed 30 characters" }

end
