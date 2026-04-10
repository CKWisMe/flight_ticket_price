module SearchRequests
  class RecommendationService
    def initialize(search_request:, source_offer_repository: SourceOfferRepository.new)
      @search_request = search_request
      @source_offer_repository = source_offer_repository
    end

    def call
      best_offer = source_offer_repository.recommendation_candidate(search_request)
      return search_request.recommendation&.destroy! unless best_offer

      explanation = "#{best_offer.display_currency} #{best_offer.normalized_total_amount.to_f.round(2)}，總旅行時間 #{best_offer.total_travel_minutes} 分鐘"
      recommendation = search_request.recommendation || search_request.build_recommendation
      recommendation.source_offer = best_offer
      recommendation.reason_code = "lowest_total_price"
      recommendation.explanation = explanation
      recommendation.ranked_at = Time.current
      recommendation.save!
      recommendation
    end

    private

    attr_reader :search_request, :source_offer_repository
  end
end
