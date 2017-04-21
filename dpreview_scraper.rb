require 'open-uri'
require 'nokogiri'
require 'json'

module DSS
  class DpreviewScraper
    REVIEWS_PREFIX = "https://www.dpreview.com/products/amazon-customer-reviews?renderMode=inline&sort=recentFirst&"

    class << self
      def get_all_data_as_json_by_category(category_name, &block)
        File.write "#{category_name}.json", 
          get_all_data(category_name, &block).to_json
      end

      private

      def get_all_data(category_name)
        data = []
        get_all_product_links(category_name).each_with_index do |link, index|
          yield(link, index) if block_given?
          data << get_data_from(link)
        end

        return data
      end

      def get_all_product_links(category_name)
        doc = Nokogiri::HTML(
          open("https://www.dpreview.com/products/#{category_name}/all?sort=view=list")
        )
        doc.css('.name a').map { |title| title.attr('href') }
      end

      def get_data_from(link)
        retries = 0
        doc = Nokogiri::HTML(open(link))

        {
          name: get_name_from(doc),
          price: get_price_from(doc),
          quick_specs: get_quick_specs_from(doc),
          amazon_reviews: get_amazon_reviews_from(doc, link)
        } 
      rescue => e
        retries += 1
        retries < 3 ? retry : puts("Couldn't connect to proxy: #{e}")
      end

      def get_name_from(doc)
        doc.at_css('.headerContainer h1')&.text
      end

      def get_price_from(doc)
        doc.at_css('.price.range .start')&.text
      end

      def get_quick_specs_from(doc)
        Hash[ *doc.css('.quickSpecs td').map(&:text).map(&:strip) ]
      end

      def get_amazon_reviews_from(doc, link)
        product_name = link[/[^\/]+$/]
        reviews_data = []
        i = 0

        loop do
          reviews_page = open(
            REVIEWS_PREFIX + "product=#{product_name}&pageIndex=#{i}", &:read)
          data = JSON.parse(
            reviews_page.sub('AmazonCustomerReviews(', '').chomp(')')
          )
          review_count = data['groups'] && data['groups'].first['reviewCount']
      
          break if review_count.nil?

          reviews_data << data['reviews']
            .select { |review| review['rating'] > 2 }
            .map { |review|
              review.select { |k, v|
                k =~ /(rating|summary|content|customerName)/ 
              }
            }

          i += 1
        end

        return reviews_data
      end
    end
  end
end