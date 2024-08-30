class SegmentsController < ApplicationController
  def new
    @segment = Segment.new
  end

  def import
    @map = Map.find(params[:map_id])
    @segment = Segment.create(map: @map)
    # import coordinates from gpx file and save them in the database
    coordinates = DataImporter.new.call(params["segment"]["gpx"].tempfile)
    coordinates.each do |lon, lat|
      Point.create(lat: lat, lon: lon, segment: @segment)
    end

    redirect_to map_path(@map)
  end
end
