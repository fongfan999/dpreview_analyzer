require 'sentiwordnet_ruby'
require 'json'
require_relative 'camera'

module Dpreview
  class Analyzer
    attr_reader :year

    def self.load_senti_dics
      SentiWordNet.load_defaults
    end

    def initialize(year)
      @year = year.to_s.gsub(' ', '-')
      @instance = SentiWordNet.new
    end

    def method_missing(method_name, arg)
      @instance.send(method_name, arg)
    end

    def sort(options = { objectivity: 0.25, by: 'asc' })
      cameras = load_reviews_file

      @data = cameras.sort do |x, y|
        x,y = y,x if options[:by] == 'desc'

        Dpreview::Camera.new(x, options[:objectivity]) <=>
          Dpreview::Camera.new(y, options[:objectivity])
      end
    end

    def save
      File.write "lib/data/ordered-#{year}.json", @data.to_json
    end

    private
      def load_reviews_file
        JSON.parse File.read(File.expand_path("#{@year}.json", 'lib/data'))
      rescue Errno::ENOENT => e
        puts "Data of year #{@year} doesn't exist in lib/data folder"
      end

      def calculate_average
        
      end
  end
end
