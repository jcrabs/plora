require 'nokogiri'
require 'faraday'
require 'concurrent'

class DataImporter

  def call(file)

    processed_data = format_raw_data(file)
    return format_matched_coordinates(processed_data)

  end

  private

  def format_raw_data(file)
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

  def get_match(coordinates, profile, radiuses)
    Concurrent::Promise.execute do
      connection = Faraday.new("https://api.mapbox.com") do |f|
        f.adapter Faraday.default_adapter
      end
      # make the API call
      response = connection.get("/matching/v5/mapbox/#{profile}/#{coordinates}") do |req|
        req.params['geometries'] = 'geojson'
        req.params['radiuses'] = radiuses
        req.params['access_token'] = ENV['MAPBOX_API_KEY']
      end
      JSON.parse(response.body)
    end
  end

  def format_matched_coordinates(data)
    formatted_data = data[:formatted_data]
    radiuses = data[:radiuses]
    # collect the promises from the API calls; make 1 API call per 50 piece data chunk
    coord_futures = formatted_data.zip(radiuses).map do |formatted_data_part, radius_part|
      Concurrent::Promises.future { get_match(formatted_data_part, "walking", radius_part) }
    end
    # collect the results once they have arrived
    begin
      coords = coord_futures.map { |future| future.value! }
      Rails.logger.info "Received #{coords.length} coordinate sets"
      coords
    rescue => error
      Rails.logger.error "An error occurred: #{error.message}"
      nil
    end
    # collect all coordinates in one array
    coordinates = []
    coords.each do |part|
      part.value["matchings"][0]["geometry"]["coordinates"].each do |pair|
        coordinates << pair
      end
    end
    return coordinates
  end
end
