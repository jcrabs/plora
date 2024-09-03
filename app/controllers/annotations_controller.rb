class AnnotationsController < ApplicationController

  def index
    @annotations = Annotation.where(map_id: params[:map_id])
    render json: @annotations
  end

  def show
    @map = Map.find(params[:id])
  end

  def new
    @annotation = Annotation.new
  end

  def create
    @map = Map.find(params[:map_id])
    @annotation = @map.annotations.new(annotation_params)
    @annotation.save
  end

  private

  def annotation_params
    params.require(:annotation).permit(:lat, :lon, :name, :description)
  end

end
