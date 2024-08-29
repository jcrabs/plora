class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
    if user_signed_in?
      @home = { lat: current_user.home_lat, lon: current_user.home_lon }
    else
      @home = { lat: 52.5200, lon: 13.4050, hide: true }
    end





    require 'nokogiri'

    file = File.open('storage/testpath-j.gpx')
    document = Nokogiri::XML(file)

    trackpoints = document.xpath('//xmlns:trkpt')

    radius = 10
    @formatted_data = []
    formatted_data_part = ""
    @radiuses = []
    radiuses_part = ""

    trackpoints.each_with_index do |point, index|
      formatted_data_part += "#{point.attr("lon")},#{point.attr("lat")};"
      radiuses_part += "#{radius};"
      if (((index + 1) % 50) == 0) || (index == (trackpoints.size - 1))
        formatted_data_part = formatted_data_part[0..-2]
        radiuses_part = radiuses_part[0..-2]
        @formatted_data << formatted_data_part
        @radiuses << radiuses_part
        # duplicate the last coordinates so the line segments will join up
        formatted_data_part = ""
        radiuses_part = ""
      end
    end

    @unformatted_data = trackpoints.map do |point|
      { lat: point.attr("lat").to_f, lon: point.attr("lon").to_f }
    end
  end
end
