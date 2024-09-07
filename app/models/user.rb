class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one_attached :photo
  has_many :maps
  has_many :points_of_interest
  has_many :explored_points_of_interest

  def avatar_tag
    if photo.attached?
      return ActionController::Base.helpers.cl_image_tag(photo.key, alt: "avatar",
             class: "avatar-bordered dropdown-toggle", id: "navbarDropdown",
             data:{bs_toggle: "dropdown"}, aria_haspopup: "true", aria_expanded: "false")
    else
      return ActionController::Base.helpers.image_tag("pallas_small.png", alt: "avatar",
             class: "avatar-bordered dropdown-toggle", id: "navbarDropdown",
             data:{bs_toggle: "dropdown"}, aria_haspopup: "true", aria_expanded: "false")
    end
  end

end
