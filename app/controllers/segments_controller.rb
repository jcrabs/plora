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

  def import_drawing
    @map = Map.find(params[:map_id])
    # import coordinates from drawn routes and save them in the database
    saveok = []
    params["coordinates"].each do |coords|
      @segment = Segment.create(map: @map)
      coords.each do |pair|
        @point = Point.new(lat: pair["lat"], lon: pair["lon"], segment: @segment)
        saveok << @point.save
      end
    end

    # send response back to frontend
    respond_to do |format|
      if saveok.all?
        format.json { render json: { success: true } }
      else
        # format.json { render json: { success: false, errors: @point.errors.full_messages }, status: :unprocessable_entity }
        format.json { render json: { success: false }, status: :unprocessable_entity }
      end
    end
  end
end
