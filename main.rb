require './dpreview_scraper'

# Pick any category from the following list below
# cameras | lenses | printers | software | mobilephones | tablets | mobileapps
DSS::DpreviewScraper.get_all_data_as_json_by_category('cameras') do |link, i|
  puts "#{i + 1} - #{link}" 
end