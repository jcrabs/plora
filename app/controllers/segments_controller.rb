class SegmentsController < ApplicationController
  def new
    @segment = Segment.new
  end

  def import
    @map = Map.find(params[:map_id])
    @segment = Segment.create(map: @map)

    @coordinates = DataImporter.new.call(params["segment"]["gpx"].tempfile)
    raise
    redirect_to map_path(@map)
  end
end
