class SegmentsController < ApplicationController
  def new
    @segment = Segment.new
  end

  def import
    @map = Map.find(params[:map_id])
    @segment = Segment.create(map: @map)
    collection = DataImporter.new.call(params["segment"]["gpx"].tempfile)
    @unformatted_data = collection[:unformatted_data]
    @formatted_data = collection[:formatted_data]
    @radiuses = collection[:radiuses]
    redirect_to map_path(@map)
  end
end
