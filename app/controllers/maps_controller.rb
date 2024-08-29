class MapsController < ApplicationController


  def index
    @maps = Map.all
  end


  def show
    @map = Map.find(params[:id])
    @markers = current_user.maps.first.segments.first.points
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




  private

  def map_params
    params.require(:map).permit(:name, :description)
  end

  def edit
  end

  def update
  end

  def destroy
  end

end
