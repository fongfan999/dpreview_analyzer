require 'open-uri'
require 'nokogiri'
require 'json'

module Dpreview
  class Scraper
    REVIEWS_URL = "https://www.dpreview.com/products/amazon-customer-reviews"

    attr_reader :year
    attr_accessor :data

    def self.get_data_from(url)
      retries = 0

      begin
        doc = Nokogiri::HTML open(url)
        return unless doc.at_css('#productPageTabs .tabs').text().include? 'Amazon'

        {
          name: doc.at_css('.headerContainer h1')&.text,
          amazon_reviews: get_amazon_reviews_from(url)
        }
      rescue => e
        retries += 1
        retries <= 3 ? retry : puts("Couldn't connect to proxy: #{e}")
      end
    end

    def initialize(year)
      @year = year
      @data = []
    end

    def scrape_amazon_reviews
      urls = get_camera_urls
      size = urls.size

      urls.each_with_index do |url, index|
        if reviews_data = Scraper.get_data_from(url)
          data << reviews_data
        end

        yield(size, index) if block_given?
      end
    end

    def save
      File.write "lib/data/#{year}.json", data.to_json
    end

    private
      def self.get_amazon_reviews_from(url)
        product_name = url[/[^\/]+$/]
        reviews_data = []
        i = 0

        loop do
          reviews_page = open(
            "#{REVIEWS_URL}?product=#{product_name}&pageIndex=#{i}", &:read)
          data = JSON.parse(
            reviews_page.sub('AmazonCustomerReviews(', '').chomp(')')
          )

          break if data['reviews'].empty?

          reviews_data << data['reviews']
            .select { |review| review['rating'] > 2 }
            .map { |review| review['content'] }

          i += 1
        end

        reviews_data.flatten
      end

      def get_camera_urls
        doc = Nokogiri::HTML(
          open("https://www.dpreview.com/products/cameras/all?view=list")
        )
        puts "Initializing ..."

        label_index = doc.css('.groupLabel').map(&:text).index(year) + 1
        doc.css(".productList tbody:nth-of-type(#{label_index}) .name a")
          .map { |title| title.attr('href') }
      end
  end
end
