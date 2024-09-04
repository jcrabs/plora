# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
require "open-uri"
require "json"

puts "Destroying all Explored points of interest..."
ExploredPointOfInterest.destroy_all
puts "Destroying all annotations..."
Annotation.destroy_all
puts "Destroying all points..."
Point.destroy_all
puts "Destroying all segments..."
Segment.destroy_all
puts "Destroying all maps..."
Map.destroy_all
puts "Destroying all POIs..."
PointOfInterest.destroy_all
puts "Destroying all users..."
User.destroy_all

puts "Creating users..."
User.create!(username: "Max Mustermann", email: "max.mustermann@example.com", password: "password", home_address: "Alexanderplatz 5, 10178 Berlin", home_lat: 52.521918, home_lon: 13.413215)
User.create!(username: "Sophie Müller", email: "sophie.mueller@example.com", password: "password", home_address: "Potsdamer Platz 10, 10785 Berlin", home_lat: 52.509648, home_lon: 13.375452)
User.create!(username: "Hans Schmidt", email: "hans.schmidt@example.com", password: "password", home_address: "Kurfürstendamm 1, 10719 Berlin", home_lat: 52.503412, home_lon: 13.332893)
User.create!(username: "Mia Meyer", email: "mia.meyer@example.com", password: "password", home_address: "Unter den Linden 4, 10117 Berlin", home_lat: 52.517037, home_lon: 13.404565)
User.create!(username: "Felix Becker", email: "felix.becker@example.com", password: "password", home_address: "Friedrichstraße 140, 10117 Berlin", home_lat: 52.519861, home_lon: 13.388165)
User.create!(username: "Emilia Fischer", email: "emilia.fischer@example.com", password: "password", home_address: "Torstraße 25, 10119 Berlin", home_lat: 52.528437, home_lon: 13.401470)
User.create!(username: "Jonas Wagner", email: "jonas.wagner@example.com", password: "password", home_address: "Karl-Marx-Allee 35, 10178 Berlin", home_lat: 52.517855, home_lon: 13.426221)
User.create!(username: "Lena Hofmann", email: "lena.hofmann@example.com", password: "password", home_address: "Schönhauser Allee 180, 10119 Berlin", home_lat: 52.536295, home_lon: 13.412234)
User.create!(username: "Paul Weber", email: "paul.weber@example.com", password: "password", home_address: "Frankfurter Allee 120, 10247 Berlin", home_lat: 52.514902, home_lon: 13.464595)
User.create!(username: "Anna Lehmann", email: "anna.lehmann@example.com", password: "password", home_address: "Görlitzer Straße 1, 10997 Berlin", home_lat: 52.503619, home_lon: 13.448775)
User.create!(username: "Lukas Schmid", email: "lukas.schmid@example.com", password: "password", home_address: "Oranienstraße 60, 10969 Berlin", home_lat: 52.500182, home_lon: 13.409643)
User.create!(username: "Laura Keller", email: "laura.keller@example.com", password: "password", home_address: "Kantstraße 152, 10623 Berlin", home_lat: 52.507778, home_lon: 13.310877)
User.create!(username: "David Braun", email: "david.braun@example.com", password: "password", home_address: "Boxhagener Straße 75, 10245 Berlin", home_lat: 52.514445, home_lon: 13.466453)
User.create!(username: "Julia Bauer", email: "julia.bauer@example.com", password: "password", home_address: "Mühlenstraße 4, 10243 Berlin", home_lat: 52.507855, home_lon: 13.448724)
User.create!(username: "Simon Wolf", email: "simon.wolf@example.com", password: "password", home_address: "Warschauer Straße 70, 10243 Berlin", home_lat: 52.505347, home_lon: 13.448200)
User.create!(username: "Clara Krüger", email: "clara.krueger@example.com", password: "password", home_address: "Prenzlauer Allee 150, 10409 Berlin", home_lat: 52.535859, home_lon: 13.430580)
User.create!(username: "Tom König", email: "tom.koenig@example.com", password: "password", home_address: "Karl-Liebknecht-Straße 30, 10178 Berlin", home_lat: 52.521242, home_lon: 13.410773)
User.create!(username: "Hanna Neumann", email: "hanna.neumann@example.com", password: "password", home_address: "Greifswalder Straße 217, 10405 Berlin", home_lat: 52.528707, home_lon: 13.433567)
User.create!(username: "Elias Schneider", email: "elias.schneider@example.com", password: "password", home_address: "Chausseestraße 20, 10115 Berlin", home_lat: 52.531997, home_lon: 13.383582)
User.create!(username: "Maya Schwarz", email: "maya.schwarz@example.com", password: "password", home_address: "Karl-Marx-Straße 110, 12043 Berlin", home_lat: 52.478204, home_lon: 13.439032)
puts "Created #{User.count} users!"


filepath = "json/berlin_fountains.geojson"
file = File.join(__dir__, filepath)
points = File.read(file)
geopoints_hash = JSON.parse(points)
puts "Creating POIs from #{filepath}"
counter = 0
geopoints_hash["features"].each do |feature|
  counter += 1
  PointOfInterest.create!(name: feature["properties"]["name"], category: feature["properties"]["amenity"].capitalize, description: "Placeholder description", lat: feature["geometry"]["coordinates"][1], lon: feature["geometry"]["coordinates"][0], user: User.first)
end
puts "Created #{counter} POIs"

filepath = "json/berlin_historical_toilets.geojson"
file = File.join(__dir__, filepath)
points = File.read(file)
geopoints_hash = JSON.parse(points)
puts "Creating POIs from #{filepath}"
geopoints_hash["features"].each do |feature|
  PointOfInterest.create!(name: feature["properties"]["name"], category: feature["properties"]["amenity"].capitalize, description: "Placeholder description", lat: feature["geometry"]["coordinates"][1], lon: feature["geometry"]["coordinates"][0], user: User.first)
end
puts "Created #{PointOfInterest.count} POIs"

puts "Attaching cat images to users!"
resources = Cloudinary::Api.resources(prefix: 'cats', type: 'upload', max_results: 20)
  if resources['resources'].empty?
    puts "No images found in the folder."
  else
    User.all.each_with_index do |user, index|
      user.photo.attach(io: URI.open("https://res.cloudinary.com/dnd9g94xw/image/upload/#{resources['resources'][index]['public_id']}"), filename: "#{resources['resources'][index]['public_id']}.jpg", content_type: "image/jpeg")
  end
  end
puts "Finished attaching cat images to users!"


puts "Creating a map per user (#{User.count})..."
User.all.each do |user|
  Map.create!(name: "#{user.username}'s map", description: "This is my map!", user: user)
end

puts "Creating annotations..."
Annotation.create!(lat: 52.510556, lon: 13.377222, name: "Sunday Picnic at Tiergarten", description: "Enjoyed a peaceful Sunday picnic by the lake.", map: Map.all.sample)
Annotation.create!(lat: 52.523332, lon: 13.412873, name: "Morning Coffee at Hackescher Markt", description: "Had the best cappuccino while people-watching.", map: Map.all.sample)
Annotation.create!(lat: 52.501364, lon: 13.457824, name: "Exploring Friedrichshain Street Art", description: "Discovered amazing murals and graffiti.", map: Map.all.sample)
Annotation.create!(lat: 52.492876, lon: 13.434568, name: "Sunset at Tempelhofer Feld", description: "Witnessed a stunning sunset over the former airport.", map: Map.all.sample)
Annotation.create!(lat: 52.509902, lon: 13.375756, name: "CinemaxX at Potsdamer Platz", description: "Caught a late-night movie at the iconic theater.", map: Map.all.sample)
Annotation.create!(lat: 52.520855, lon: 13.409419, name: "Climbing the TV Tower", description: "Amazing 360-degree views from the top of Berlin.", map: Map.all.sample)
Annotation.create!(lat: 52.530815, lon: 13.384961, name: "Vintage Shopping on Oderberger Strasse", description: "Found some unique vintage pieces at local shops.", map: Map.all.sample)
Annotation.create!(lat: 52.477946, lon: 13.437218, name: "Neukölln Flea Market", description: "Hunted for treasures at the Sunday flea market.", map: Map.all.sample)
Annotation.create!(lat: 52.512345, lon: 13.395798, name: "Brunch at Café Einstein", description: "Delicious brunch in a classic Berlin café.", map: Map.all.sample)
Annotation.create!(lat: 52.545724, lon: 13.351289, name: "Humboldthain Park Bunker Tour", description: "Explored WWII history on a guided bunker tour.", map: Map.all.sample)
Annotation.create!(lat: 52.521926, lon: 13.407425, name: "Berlin Cathedral Visit", description: "Admired the architecture and learned about its history.", map: Map.all.sample)
Annotation.create!(lat: 52.486315, lon: 13.428618, name: "Stroll through Viktoriapark", description: "Walked up to the waterfall and enjoyed city views.", map: Map.all.sample)
Annotation.create!(lat: 52.512622, lon: 13.392309, name: "Museum Island Tour", description: "Visited multiple museums in one day on Museum Island.", map: Map.all.sample)
Annotation.create!(lat: 52.540893, lon: 13.413142, name: "Pankow Brewery Experience", description: "Sampled local craft beers at a small brewery.", map: Map.all.sample)
Annotation.create!(lat: 52.475824, lon: 13.324165, name: "Visit to Teufelsberg", description: "Hiked to the top of Teufelsberg for urban exploration.", map: Map.all.sample)
Annotation.create!(lat: 52.499514, lon: 13.335571, name: "Kurfürstendamm Shopping Spree", description: "Splurged on fashion at Berlin's famous shopping avenue.", map: Map.all.sample)
Annotation.create!(lat: 52.537855, lon: 13.424148, name: "Picnic at Mauerpark", description: "Had a laid-back picnic while enjoying the vibrant atmosphere.", map: Map.all.sample)
Annotation.create!(lat: 52.504541, lon: 13.419052, name: "Walk Along the East Side Gallery", description: "Admired the murals on the longest surviving piece of the Berlin Wall.", map: Map.all.sample)
Annotation.create!(lat: 52.516875, lon: 13.389946, name: "Lunch at Gendarmenmarkt", description: "Savored traditional German food at a café on the square.", map: Map.all.sample)
Annotation.create!(lat: 52.493582, lon: 13.418920, name: "Exploring Bergmannkiez", description: "Wandered through charming streets full of boutiques and cafes.", map: Map.all.sample)
puts "Created #{Annotation.count} annotations!"

filepath = "/json/ExamplePoints35kclean.json"

puts "Loading geopoints from #{file}"
file = File.join(__dir__, filepath)
points = File.read(file)
geopoints_hash = JSON.parse(points)
puts "Creating an array of points..."
geopoints_array = []
geopoints_hash["points"].each do |record|
  geopoints_array.append([record["lat"], record["lon"]])
end
puts "Added #{geopoints_array.count} points to the array."
puts "Three samples to confirm contents below"
p geopoints_array.sample(3)

puts "Creating 20 segments..."
Map.all.each do |map|
  Segment.create!(map: map)
  Segment.create!(map: map)
  Segment.create!(map: map)
end

points = 100

puts "Here's a segment slice to show you what it looks like."
i = (0 .. (geopoints_array.length - 3)).to_a.sample
p geopoints_array[i...(i + 3)]

puts "Creating #{points} points per segment..."
Segment.all.each do |segment|
  i = (0 .. (geopoints_array.length - points)).to_a.sample
  sample_range = geopoints_array[i...(i + points)]
  sample_range.each do |point|
    Point.create!(lat: point[0], lon: point[1], segment: segment)
  end
end

# This is going to take a while
# so maybe comment it out if you don't want to view the entire database worth of points.
#
# puts "Creating extra user with all points"
# User.create!(username: "Big Data", email: "bigdata@example.com", password: "password", home_address: "Rudi-Dutschke-Straße 26, 10969 Berlin", home_lat: 52.506892, home_lon: 13.391452)
# puts "Attaching cat image to #{User.last.username}"
# resources = Cloudinary::Api.resources(prefix: 'bigdata', type: 'upload', max_results: 1)
#   if resources['resources'].empty?
#     puts "No images found in the folder."
#   else
#     puts "Attaching #{resources['resources'][0]['public_id']}.jpg"
#     User.last.photo.attach(io: URI.open("https://res.cloudinary.com/dnd9g94xw/image/upload/#{resources['resources'][0]['public_id']}"), filename: "#{resources['resources'][0]['public_id']}.jpg", content_type: "image/jpeg")
#   end
# puts "User #{User.last.username} now has #{User.last.photo}.jpg attached!"
# puts "Creating a map for user: #{User.last.username}, email: #{User.last.email}, password: 'password'"
# Map.create!(name: "#{User.last.username}'s map", description: "This is the BIG map!", user: User.last)
# puts "Creating a BIG segment for #{User.last.username}"
# Segment.create!(map: Map.last)
# geopoints_array.each do |lat, lon|
#   Point.create!(lat: lat, lon: lon, segment: Segment.last)
# end
# puts "Finished creating a BIG segment with #{geopoints_array.size} points."
