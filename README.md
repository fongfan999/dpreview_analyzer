# Welcome to Dpreview Analyzer
This tool will get and filter Amazon reviews about **Camera** that are rated 3-stars or above. Then, using **SentiWordNet** to reject and sort.

# Installation
- `git clone https://github.com/fongfan999/dpreview_analyzer`
- `cd dpreview_analyzer`
- `bundle install`

# Usage
```ruby
# From https://www.dpreview.com/products/cameras/all?view=list
available_years = [
  "2017", "2016", "2015", "2014", "2013", "2012", "2011", "2010", "2009",
  "2008", "2007", "2006", "2005", "2004", "2003", "2002", "2001", "2000",
  "1999", "1998", "1997", "1996", "1995", "1994", "Unknown year"
]
year = available_years.sample

# Example
  scraper = Dpreview::Scraper.new(year)
  scraper.scrape_amazon_reviews
  scraper.save

## --------------------------------------------------------------------------
# Load the default sentiment dictionaries
Dpreview::Analyzer.load_senti_dics

# Example
  analyzer = Dpreview::Analyzer.new(year)
  analyzer.sort(objectivity: 0.25, by: 'asc')
  analyzer.save
````
