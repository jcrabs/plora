require 'nokogiri'

class DataImporter

  def call(file)
    document = Nokogiri::XML(file)

    trackpoints = document.xpath('//xmlns:trkpt')

    # radius = the maximum distance a coordinate can be moved to snap to the road network, in meters
    # min. 0.0, max 50.0, default 5.0
    radius = 10
    # data needs to be a semicolon-separated list of {longitude},{latitude} coordinate pairs to visit in order
    formatted_data = []
    formatted_data_part = ""
    # radiuses needs to be a semicolon-separated list
    # the number of radiuses must be the same as the number of coordinates in the request
    radiuses = []
    radiuses_part = ""

    trackpoints.each_with_index do |point, index|
      formatted_data_part += "#{point.attr("lon")},#{point.attr("lat")};"
      radiuses_part += "#{radius};"
      # max of 50 radiuses per API call -> split the data into 50 piece chunks
      if (((index + 1) % 50) == 0) || (index == (trackpoints.size - 1))
        # remove the last ;
        formatted_data_part = formatted_data_part[0..-2]
        radiuses_part = radiuses_part[0..-2]

        formatted_data << formatted_data_part
        radiuses << radiuses_part

        formatted_data_part = ""
        radiuses_part = ""
      end
    end

    # for testing purposes: for displaying the raw data as markers
    unformatted_data = trackpoints.map do |point|
      { lat: point.attr("lat").to_f, lon: point.attr("lon").to_f }
    end

    return {unformatted_data: unformatted_data, formatted_data: formatted_data, radiuses: radiuses}
  end
end
