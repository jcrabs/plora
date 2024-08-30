class Map < ApplicationRecord
  belongs_to :user
  has_many :annotations, dependent: :destroy
  has_many :segments, dependent: :destroy

  validates :description, length: { maximum: 30, message: "Description should not exceed 30 characters" }

end
