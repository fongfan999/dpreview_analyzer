require 'open-uri'
require 'nokogiri'
require 'json'

module DSS
  class DpreviewScraper
    class << self
      def get_all_data_as_json_by_category(category_name, &block)
        File.write 'data.json', get_all_data(category_name, &block) 
      end

      private

      def get_all_data(category_name)
        get_all_product_links(category_name).each_with_index do |link, index|
          yield(link, index) if block_given?
          get_data_from(link)
        end
      end

      def get_all_product_links(category_name)
        doc = Nokogiri::HTML(
          open("https://www.dpreview.com/products/#{category_name}/all?sort=view=list")
        )
        doc.css('.name a').map { |title| title.attr('href') }
      end

      def get_data_from(link)
        doc = Nokogiri::HTML(open(link))

        {
          name: get_name_from(doc), 
          price: get_price_from(doc)
        }.merge get_quick_specs_from(doc)
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
    end
  end
end