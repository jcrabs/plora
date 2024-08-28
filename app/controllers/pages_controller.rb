class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
    if user_signed_in?
      @home = { lat: current_user.home_lat, lon: current_user.home_lon }
    else
      @home = { lat: 52.5200, lon: 13.4050, hide: true }
    end





    require 'nokogiri'

    file = File.open('storage/testpath.gpx')
    document = Nokogiri::XML(file)

    trackpoints = document.xpath('//xmlns:trkpt')

    radiuses = ""
    trackpoints.count.times do
      radiuses += "5;"
    end
    @radiuses = radiuses[0..-2]

    formatted_data = ""
    trackpoints.map do |point|
      formatted_data += "#{point.attr("lon")},#{point.attr("lat")};"
    end
    @formatted_data = formatted_data[0..-2]

    @unformatted_data = trackpoints.map do |point|
      { lat: point.attr("lat").to_f, lon: point.attr("lon").to_f }
    end
  end
end
