
require "open-uri"

# destination directory
@directory = 'Backtrack-iOS-SDK/Assets/'
# list of icons to fetch
maki_icons   = ["circle-stroked", "circle", "square-stroked", "square", "triangle-stroked", "triangle", "star-stroked", "star", "cross", "marker-stroked", "marker", "religious-jewish", "religious-christian", "religious-muslim", "cemetery", "rocket", "airport", "heliport", "rail", "rail-metro", "rail-light", "bus", "fuel", "parking", "parking-garage", "airfield", "roadblock", "ferry", "harbor", "bicycle", "park", "park2", "museum", "lodging", "monument", "zoo", "garden", "campsite", "theatre", "art-gallery", "pitch", "soccer", "america-football", "tennis", "basketball", "baseball", "golf", "swimming", "cricket", "skiing", "school", "college", "library", "post", "fire-station", "town-hall", "police", "prison", "embassy", "beer", "restaurant", "cafe", "shop", "fast-food", "bar", "bank", "grocery", "cinema", "pharmacy", "hospital", "danger", "industrial", "warehouse", "commercial", "building", "place-of-worship", "alcohol-shop", "logging", "oil-well", "slaughterhouse", "dam", "water", "wetland", "disability", "telephone", "emergency-telephone", "toilets", "waste-basket", "music", "land-use", "city", "town", "village", "farm", "bakery", "dog-park", "lighthouse", "clothing-store", "polling-place", "playground", "entrance", "heart", "london-underground", "minefield", "rail-underground", "rail-above", "camera", "laundry", "car", "suitcase", "hairdresser", "chemist", "mobilephone", "scooter", "gift", "ice-cream", "dentist"]
# color of choice
color        = "2793B8"
# template for the urls
url_template = "http://a.tiles.mapbox.com/v3/marker/pin-m-%{icon}+#{color}%{size}.png"

def fetch_photo(name, url)
	puts "Downloading: " + name

	begin 
		open(url) {|f|
		   File.open(@directory+name,"wb") do |file|
		     file.puts f.read
		   end
		}
	rescue Exception => msg
		puts "Failed... Skipping. ("+msg.to_s+")"
	end
end

maki_icons.each do |icon|
	# download photos
	fetch_photo(icon+'.png', url_template % {icon: icon, size: ''})
	fetch_photo(icon+'@2x.png', url_template % {icon: icon, size: '@2x'})
end