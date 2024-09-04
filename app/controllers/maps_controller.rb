class MapsController < ApplicationController

  def index
    @maps = current_user.maps
    @segments_coordinates = {}
    @maps.each do |map|
      @segments_coordinates[map.id] = {}
      map.segments.each do |segment|
        points = []
        segment.points.each do |pair|
          point_coordinates = {
            lat: pair.lat,
            lon: pair.lon
          }
          points << point_coordinates
        end
        @segments_coordinates[map.id][segment.id] = points
      end
    end
  end

  def show
    @expois = ExploredPointOfInterest.where(user: current_user)
    @pois = PointOfInterest.all
    @pois = @pois.map do |poi|
      poi_hash = poi.attributes
      poi_hash["explored"] = @expois.where(point_of_interest:poi).exists?
      poi_hash
    end
    
    # display map:
    @map = Map.find(params[:id])
    # for the new segment creation form:
    @segment = Segment.new

    # display existing segments on the map:
    @segments = Segment.where(map: @map)
    ## prepare coordinates to be passed to the view
    @segments_coordinates = {}
    @segments.each do |segment|
      points = []
      segment.points.each do |pair|
        point_coordinates = {
          lat: pair.lat,
          lon: pair.lon
        }
        points << point_coordinates
      end
      @segments_coordinates[segment.id] = points
    end
  end

  def new
    @map = Map.new
  end

  def create
    @map = Map.new(map_params)
    @map.user = current_user
    @map.save
    redirect_to maps_path(@map)
  end

  def edit
    @map = Map.find(params[:id])
  end

  def update
    @map = Map.find(params[:id])
    if @map.update(map_params)
      redirect_to maps_path
    else
      render :edit
    end
  end

  def destroy
    @map = Map.find(params[:id])
    @map.destroy
    redirect_to maps_path, status: :see_other
  end

  private

  def map_params
    params.require(:map).permit(:name, :description)
  end

end
