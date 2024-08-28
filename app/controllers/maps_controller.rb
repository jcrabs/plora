class MapsController < ApplicationController


  def index
  end

  def show
    @map = Map.find(params[:id])
    @markers = current_user.maps.first.segments.first.points
  end

  def new
  end

  def create
  end

  def edit
  end

  def update
  end

  def destroy
  end

end
