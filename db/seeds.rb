# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
require "open-uri"
require "json"

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

puts "Creating POIs..."
PointOfInterest.create!(name: "Brandenburg Gate", category: "Historical Building", description: "Iconic neoclassical monument symbolizing Berlin's reunification.", lat: 52.516275, lon: 13.377704, user: User.all.sample)
PointOfInterest.create!(name: "Reichstag Building", category: "Historical Building", description: "Germany's parliament building with a modern glass dome.", lat: 52.518623, lon: 13.376198, user: User.all.sample)
PointOfInterest.create!(name: "Berlin Cathedral", category: "Historical Building", description: "Impressive baroque cathedral on Museum Island.", lat: 52.519366, lon: 13.401027, user: User.all.sample)
PointOfInterest.create!(name: "Charlottenburg Palace", category: "Historical Building", description: "Former royal palace with lavish gardens.", lat: 52.520221, lon: 13.295707, user: User.all.sample)
PointOfInterest.create!(name: "Potsdamer Platz", category: "Historical Building", description: "Historic square now a major urban center.", lat: 52.509648, lon: 13.375452, user: User.all.sample)
PointOfInterest.create!(name: "Gendarmenmarkt", category: "Historical Building", description: "One of Berlin's most beautiful squares, home to the Konzerthaus.", lat: 52.513864, lon: 13.392617, user: User.all.sample)
PointOfInterest.create!(name: "Kaiser Wilhelm Memorial Church", category: "Historical Building", description: "War-damaged church symbolizing Berlin's resilience.", lat: 52.507404, lon: 13.334915, user: User.all.sample)
PointOfInterest.create!(name: "Sanssouci Palace", category: "Historical Building", description: "Frederick the Great's summer palace in nearby Potsdam.", lat: 52.401678, lon: 13.038563, user: User.all.sample)
PointOfInterest.create!(name: "Berliner Dom", category: "Historical Building", description: "Stunning baroque cathedral with a rich history.", lat: 52.519444, lon: 13.401417, user: User.all.sample)
PointOfInterest.create!(name: "Checkpoint Charlie", category: "Historical Building", description: "Famous Cold War border crossing point.", lat: 52.507443, lon: 13.390391, user: User.all.sample)
PointOfInterest.create!(name: "Red City Hall", category: "Historical Building", description: "Berlin's city hall with a distinctive red brick facade.", lat: 52.518611, lon: 13.408333, user: User.all.sample)
PointOfInterest.create!(name: "Victory Column", category: "Historical Building", description: "Monument commemorating Prussian victories, offering great views.", lat: 52.514444, lon: 13.350278, user: User.all.sample)
PointOfInterest.create!(name: "Pergamon Museum", category: "Historical Building", description: "Home to ancient artifacts including the Pergamon Altar.", lat: 52.521114, lon: 13.396614, user: User.all.sample)
PointOfInterest.create!(name: "Humboldt University", category: "Historical Building", description: "One of Berlin's oldest universities, established in 1810.", lat: 52.518611, lon: 13.393611, user: User.all.sample)
PointOfInterest.create!(name: "Neue Wache", category: "Historical Building", description: "Memorial to the victims of war and tyranny.", lat: 52.5175, lon: 13.395278, user: User.all.sample)
PointOfInterest.create!(name: "Bellevue Palace", category: "Historical Building", description: "Official residence of the President of Germany.", lat: 52.516389, lon: 13.348889, user: User.all.sample)
PointOfInterest.create!(name: "Berlin State Opera", category: "Historical Building", description: "Historic opera house on Unter den Linden boulevard.", lat: 52.517083, lon: 13.393611, user: User.all.sample)
PointOfInterest.create!(name: "Old Museum", category: "Historical Building", description: "One of Berlin's oldest museums, housing classical antiquities.", lat: 52.520833, lon: 13.398611, user: User.all.sample)
PointOfInterest.create!(name: "Grunewald Tower", category: "Historical Building", description: "Historic lookout tower with panoramic views over Berlin.", lat: 52.454444, lon: 13.205278, user: User.all.sample)
PointOfInterest.create!(name: "Olympic Stadium", category: "Historical Building", description: "Venue for the 1936 Olympics, now a major sports arena.", lat: 52.514444, lon: 13.239444, user: User.all.sample)
PointOfInterest.create!(name: "Schloss Köpenick", category: "Historical Building", description: "Baroque palace located on an island in the Dahme River.", lat: 52.444444, lon: 13.580556, user: User.all.sample)
PointOfInterest.create!(name: "Bode Museum", category: "Historical Building", description: "Museum on Museum Island, known for sculptures and Byzantine art.", lat: 52.522778, lon: 13.396944, user: User.all.sample)
PointOfInterest.create!(name: "Nikolaikirche", category: "Historical Building", description: "Berlin's oldest church, dating back to the 13th century.", lat: 52.516944, lon: 13.408333, user: User.all.sample)
PointOfInterest.create!(name: "Altes Stadthaus", category: "Historical Building", description: "Historic city hall, now used for administrative purposes.", lat: 52.515833, lon: 13.409444, user: User.all.sample)
PointOfInterest.create!(name: "Hackesche Höfe", category: "Historical Building", description: "Complex of courtyards, a prime example of Art Nouveau architecture.", lat: 52.525556, lon: 13.401944, user: User.all.sample)
PointOfInterest.create!(name: "Deutsches Historisches Museum", category: "Historical Building", description: "Museum showcasing German history from the Middle Ages to the present.", lat: 52.517222, lon: 13.396111, user: User.all.sample)
PointOfInterest.create!(name: "Kulturforum", category: "Historical Building", description: "Cultural center home to museums, a library, and concert halls.", lat: 52.507778, lon: 13.367778, user: User.all.sample)
PointOfInterest.create!(name: "Alte Nationalgalerie", category: "Historical Building", description: "Museum on Museum Island, displaying 19th-century art.", lat: 52.520556, lon: 13.398056, user: User.all.sample)
PointOfInterest.create!(name: "Berlin Wall Memorial", category: "Historical Building", description: "Site commemorating the division of Berlin by the Berlin Wall.", lat: 52.535833, lon: 13.389444, user: User.all.sample)
PointOfInterest.create!(name: "Neue Nationalgalerie", category: "Historical Building", description: "Modern art museum with a striking glass and steel design.", lat: 52.507778, lon: 13.368333, user: User.all.sample)
PointOfInterest.create!(name: "St. Hedwig's Cathedral", category: "Historical Building", description: "Berlin's Roman Catholic cathedral, modeled after the Pantheon in Rome.", lat: 52.517222, lon: 13.395278, user: User.all.sample)
PointOfInterest.create!(name: "Berliner Fernsehturm", category: "Historical Building", description: "Iconic TV tower with panoramic views of the city.", lat: 52.520833, lon: 13.409444, user: User.all.sample)
PointOfInterest.create!(name: "French Cathedral", category: "Historical Building", description: "One of two cathedrals on Gendarmenmarkt, symbolizing religious tolerance.", lat: 52.513056, lon: 13.393611, user: User.all.sample)
PointOfInterest.create!(name: "Zeughaus Berlin", category: "Historical Building", description: "The oldest surviving building on Unter den Linden, now a museum.", lat: 52.5175, lon: 13.396111, user: User.all.sample)
PointOfInterest.create!(name: "Rotes Rathaus", category: "Historical Building", description: "Berlin's town hall, notable for its distinctive red brick architecture.", lat: 52.518611, lon: 13.408056, user: User.all.sample)
PointOfInterest.create!(name: "Topography of Terror", category: "Historical Building", description: "Museum documenting Nazi atrocities, located on the former Gestapo site.", lat: 52.5075, lon: 13.381111, user: User.all.sample)
PointOfInterest.create!(name: "Palace of Tears", category: "Historical Building", description: "Former border crossing point, now a museum on divided Berlin.", lat: 52.521111, lon: 13.386944, user: User.all.sample)
PointOfInterest.create!(name: "Villa Liebermann", category: "Historical Building", description: "Historic villa, now a museum dedicated to artist Max Liebermann.", lat: 52.445833, lon: 13.172222, user: User.all.sample)
PointOfInterest.create!(name: "Bebelplatz", category: "Historical Building", description: "Public square known for the Nazi book burning memorial.", lat: 52.517778, lon: 13.393056, user: User.all.sample)
PointOfInterest.create!(name: "Berlin Philharmonie", category: "Historical Building", description: "World-renowned concert hall, known for its unique architecture.", lat: 52.509167, lon: 13.369444, user: User.all.sample)
puts "Created #{PointOfInterest.count} POIs!"

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
  Map.create!(name: "#{user.username}'s map", description: "This is my map. There are many like it, but this one is mine.", user: user)
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

filepath = "/json/ExamplePoints35k.json"

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
puts "Creating extra user with all points."
User.create!(username: "Big Data", email: "bigdata@example.com", password: "password", home_address: "Rudi-Dutschke-Straße 26, 10969 Berlin", home_lat: 52.506892, home_lon: 13.391452)
puts "Creating a map for user: #{User.last.username}, email: #{User.last.email}, password: 'password'"
Map.create!(name: "#{User.last.username}'s map", description: "This is my map. There are many like it, but this one is mine.", user: User.last)
puts "Creating a BIG segment for #{User.last.username}"
Segment.create!(map: Map.last)
geopoints_array.each do |lat, lon|
  Point.create!(lat: lat, lon: lon, segment: Segment.last)
end
