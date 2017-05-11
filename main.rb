require_relative 'lib/dpreview/scraper'
<<<<<<< HEAD
year_get = 2007
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
}
  `git add .`
  `git commit -m "Update data #{year_get}"`
  `git push`
=======

# Please pick year from https://www.dpreview.com/products/cameras/all?view=list
year = 2011

scraper = Dpreview::Scraper.new(year)
scraper.scrape_amazon_reviews do |size, index|
  puts "#{index + 1} - #{size}"
end
scraper.save

`git add .`
`git commit -m "Update data #{year}"`
`git push`

>>>>>>> 56d2b19f495e8f02dedc66ea116c7888c8ac15c7
