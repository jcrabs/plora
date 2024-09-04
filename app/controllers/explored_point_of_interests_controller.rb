class ExploredPointOfInterestsController < ApplicationController
  def create
    @explored_point_of_interest = ExploredPointOfInterest.create!(user: current_user, point_of_interest_id: params["id"])
  end

  def destroy
    @explored_point_of_interest = ExploredPointOfInterest.find_by(user: current_user, point_of_interest_id: params["id"])
    @explored_point_of_interest.destroy
  end
end
