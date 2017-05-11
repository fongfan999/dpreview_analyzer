require 'sentiwordnet_ruby'

module Dpreview
  class Camera
    def initialize(camera, objectivity)
      @objectivity = objectivity
      @review_scores = camera['amazon_reviews'].map do |review|
        SentiWordNet.new.get_score(review)
      end
    end

    def <=>(other)
      self.calculate_average_score <=> other.calculate_average_score
    end

    def calculate_average_score
      filtered_scores = @review_scores.reject { |score| score < @objectivity }

      return 0.0 if filtered_scores.empty?
      filtered_scores.reduce(:+) / filtered_scores.size
    end
  end
end
