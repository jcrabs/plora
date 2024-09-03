require 'json'
require 'nokogiri'
require 'faraday'
require 'concurrent'

class DataImporter

  def call(file, options = {})
    # imports segments with coordinates from files, returns an array with segments with matched coordinates

    case options[:format]
    when :gpx
      extracted_segment = extract_gpx(file)
      extracted_segments = [extracted_segment]
    when :json
      extracted_segments = extract_JSON(file)
    end

    processed_data = []
    extracted_segments.each do |segment|
      formatted_data = format_extracted_data(segment)
      processed_data << format_matched_coordinates(formatted_data)
    end

    return processed_data
  end

  private

  def extract_gpx(file)
    # extracts coordinates from GPX

    document = Nokogiri::XML(file)
    trackpoints = document.xpath('//xmlns:trkpt')

    extracted_coordinates = []
    trackpoints.each do |point|
      extracted_coordinates << [point.attr("lon"), point.attr("lat")]
    end

    return extracted_coordinates
  end

  def extract_JSON(file)
    # extracts coordinates from JSON

    all_segments = []
    file["coordinates"].each do |segment|
      extracted_coordinates = []
      segment.each do |point|
        extracted_coordinates << [point["lon"], point["lat"]]
      end
      all_segments << extracted_coordinates
    end

    return all_segments
  end

  def format_extracted_data(data)
    # formats data for the mapbox API

    # radius = the maximum distance a coordinate can be moved to snap to the road network, in meters
    # min. 0.0, max 50.0, default 5.0
    radius = 10
    # data needs to be a semicolon-separated list of {longitude},{latitude} coordinate pairs to visit in order
    formatted_data = []
    formatted_data_part = []
    # radiuses needs to be a semicolon-separated list
    # the number of radiuses must be the same as the number of coordinates in the request
    radiuses = []
    data.each_with_index do |points, index|
      formatted_data_part << points.join(",")
      # max of 50 radiuses per API call -> split the data into 50 piece chunks
      if (((index + 1) % 50) == 0) || (index == (data.size - 1))
        radiuses_part = formatted_data_part.map { radius }
        radiuses << radiuses_part.join(";")

        formatted_data << formatted_data_part.join(";")
        formatted_data_part = []
      end
    end

    return {formatted_data: formatted_data, radiuses: radiuses}
  end

  def get_match(coordinates, profile, radiuses)
    # gets coordinates matched to the closest paths/sidewalks/roads

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
    # gets matched coordinates from multiple API calls, collects them in a single array

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
      if part.value["matchings"] == []
        coordinates << part.value["message"]
      else
        part.value["matchings"][0]["geometry"]["coordinates"].each do |pair|
          coordinates << pair
        end
      end
    end
    return coordinates
  end
end
