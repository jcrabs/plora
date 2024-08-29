class SegmentsController < ApplicationController
  def new
    @segment = Segment.new
  end

  def create
    @map = Map.find(params[:map_id])
    @segment = Segment.create(map: @map)
    redirect_to maps_path(@map)
  end
end
