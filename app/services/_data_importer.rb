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
    if options[:mode] == "freeform" # don't match the coordinates
      extracted_segments.each do |segment|
        processed_data << segment
      end
    else # match the coordinates
      extracted_segments.each do |segment|
        preformatted_data = split_coordinates(segment, 50)
        matched_data = make_API_calls(preformatted_data)
        processed_data << format_matched_coordinates(matched_data)
      end
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

  def split_coordinates(coords, part_length)
    # max of 50 radiuses per API call -> default: split the data into 50 piece chunks

    return_list = []
    current_part = []
    coords.each_with_index do |points, index|
      current_part << points.join(",")
      # when we have reached a chunk length of part_length,
      # or when we have reached the end of the track:
      # finish this chunk and start the next one
      if (((index + 1) % part_length) == 0) || (index == (coords.size - 1))
        return_list << current_part
        current_part = []
      end
    end
    return return_list
  end

  def get_match(coordinates, profile, radius)
    # gets coordinates matched to the closest paths/sidewalks/roads

    Concurrent::Promise.execute do
      connection = Faraday.new("https://api.mapbox.com") do |f|
        f.adapter Faraday.default_adapter
      end
      # formatted_coordinates needs to be a semicolon-separated list of
      # {longitude},{latitude} coordinate pairs to visit in order
      formatted_coordinates = coordinates.join(";")
      # make the API call
      response = connection.get("/matching/v5/mapbox/#{profile}/#{formatted_coordinates}") do |req|
        req.params['geometries'] = 'geojson'
        # the number of radiuses must be the same as the number of coordinates in the request
        req.params['radiuses'] = ([radius] * coordinates.length).join(";")
        req.params['access_token'] = ENV['MAPBOX_API_KEY']
      end
      parsed_response = JSON.parse(response.body)
      if parsed_response["message"]
        Rails.logger.info "Received response #{parsed_response["message"]} for input coordinates #{coordinates}"
      end

      # if there are no matchings for a chunk:
      if parsed_response["matchings"] == []
        # if the chunk was small: skip it
        if coordinates.length <= 2
          []
        # split the chunk in halves and try each half;
        # recursively until there are matches or the chunk gets too small
        else
          middle = coordinates.length / 2
          first_half_response = get_match(coordinates[0..middle], profile, radius).value
          second_half_response = get_match(coordinates[middle..-1], profile, radius).value
          # only keep the halves that contain matchings, skip others
          if first_half_response && second_half_response
            first_half_response + second_half_response
          elsif first_half_response
            first_half_response
          elsif second_half_response
            second_half_response
          else
            []
          end
        end
      # if there are matchings for a chunk: get the matched coordinates
      else
        parsed_response["matchings"][0]["geometry"]["coordinates"]
      end
    end
  end

  def make_API_calls(formatted_data)
    # gets matched coordinates from multiple API calls, collects them in a single array

    # radius = the maximum distance a coordinate can be moved to snap to the road network, in meters
    # min. 0.0, max 50.0, default 5.0
    radius = 10
    # collect the promises from the API calls; make 1 API call per 50 piece data chunk
    coord_futures = formatted_data.each_with_index.map do |formatted_data_part, index|
      Concurrent::Promises.future do
        result = get_match(formatted_data_part, "walking", radius)
        [index, result]
      end
    end
    # collect the results
    begin
      coords = {}
      coord_futures.map do |promise|
        index, result = promise.value
        coords[index] = result
      end
      Rails.logger.info "Received #{coords.length} coordinate sets"
      coords
    rescue => error
      Rails.logger.error "An error occurred: #{error.message}"
      nil
    end
  end

  def format_matched_coordinates(data)
    # collect all matched coordinates in a single array for drawing a single line

    coordinates = []
    data.sort.each do |part|
      part[1].value.each do |pair|
        coordinates << pair
      end
    end
    return coordinates
  end
end
