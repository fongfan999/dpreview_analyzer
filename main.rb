require_relative 'lib/dpreview/scraper'

# Please pick year from https://www.dpreview.com/products/cameras/all?view=list

scraper = Dpreview::Scraper.new('2014')
scraper.scrape_amazon_reviews do |size, index|
  puts "#{index + 1} - #{size}"
end
scraper.save

`git add-commit -m "Update data 2014"`
`git push`

