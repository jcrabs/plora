class PointsController < ApplicationController
  def new
    @point = Point.new
  end

  def create

  end

  def import
    file = params["map"]["gpx"].tempfile
    data = File.read(file)
  end
end
