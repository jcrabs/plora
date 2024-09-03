class SegmentsController < ApplicationController
  def new
    @segment = Segment.new
  end

  def import
    @map = Map.find(params[:map_id])
    # import coordinates from gpx file and save them in the database
    segments = DataImporter.new.call(params["segment"]["gpx"].tempfile, format: :gpx)
    segments.each do |coordinates|
      @segment = Segment.create(map: @map)
      coordinates.each do |lon, lat|
        Point.create(lat: lat, lon: lon, segment: @segment)
      end
    end

    redirect_to map_path(@map)
  end

  def import_drawing
    @map = Map.find(params[:map_id])
    # import coordinates from drawn routes and save them in the database
    segments = DataImporter.new.call(params, format: :json)
    saveok = []
    errors = []
    segments.each do |coordinates|
      # unless there was an error: create new points
      unless coordinates[0].class == String
        @segment = Segment.create(map: @map)
        coordinates.each do |lon, lat|
          @point = Point.new(lat: lat, lon: lon, segment: @segment)
          saveok << @point.save
        end
      else
        saveok << false
        errors << coordinates[0]
      end
    end

    # send response back to frontend
    respond_to do |format|
      if saveok.all?
        format.json { render json: { success: true } }
      else
        # format.json { render json: { success: false, errors: @point.errors.full_messages }, status: :unprocessable_entity }
        format.json { render json: { success: false, errors: errors }, status: :unprocessable_entity }
      end
    end
  end

end
