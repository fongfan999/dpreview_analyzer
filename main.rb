require_relative 'lib/dpreview/scraper'
year_get = 2008
# Please pick year_get from https://www.dpreview.com/products/cameras/all?view=list
loop { 
  puts year_get
  scraper = Dpreview::Scraper.new(year_get)
  scraper.scrape_amazon_reviews do |size, index|
    puts "#{index + 1} - #{size}"
  end
  scraper.save
  year_get -= 1
  break if year_get == 1993
  `git add-commit -m "Update data"`
}
