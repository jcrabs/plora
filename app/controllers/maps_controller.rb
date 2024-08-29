class MapsController < ApplicationController


  def index
    @maps = Map.all
  end


  def show
    @map = Map.find(params[:id])
    @segment = Segment.new
    # if @map.segments.present?
    #   @markers = @map.segments.points
    # end
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
    @map.update(map_params)
    redirect_to maps_path(@map)
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

  private

  def map_params
    params.require(:map).permit(:name, :description)
  end
end
