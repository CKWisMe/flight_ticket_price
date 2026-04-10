module SearchRequests
  class StatusService
    def initialize(search_request:, source_offer_repository: SourceOfferRepository.new)
      @search_request = search_request
      @source_offer_repository = source_offer_repository
    end

    def status_payload
      {
        search_request_id: search_request.id,
        status: search_request.status,
        source_statuses: serialized_source_statuses
      }
    end

    def results_payload(sort: "price")
      {
        search_request_id: search_request.id,
        status: search_request.status,
        display_currency: search_request.display_currency,
        recommendation: serialized_recommendation,
        source_statuses: serialized_source_statuses,
        offers: source_offer_repository.for_search_request(search_request, sort: sort).map { |offer| serialize_offer(offer) }
      }
    end

    private

    attr_reader :search_request, :source_offer_repository

    def serialized_source_statuses
      search_request.source_statuses.order(:source_key).map do |status|
        {
          source_key: status.source_key,
          status: status.status,
          error_code: status.error_code,
          fetched_at: status.fetched_at
        }
      end
    end

    def serialized_recommendation
      return nil unless search_request.recommendation

      {
        offer_id: search_request.recommendation.source_offer_id,
        reason_code: search_request.recommendation.reason_code,
        explanation: search_request.recommendation.explanation
      }
    end

    def serialize_offer(offer)
      {
        offer_id: offer.id,
        source_key: offer.source_key,
        original_currency: offer.original_currency,
        display_currency: offer.display_currency,
        total_amount: offer.total_amount.to_f,
        normalized_total_amount: offer.normalized_total_amount.to_f,
        direct_flight: offer.direct_flight,
        total_travel_minutes: offer.total_travel_minutes,
        outbound_departure_at: offer.outbound_departure_at,
        outbound_arrival_at: offer.outbound_arrival_at,
        return_departure_at: offer.return_departure_at,
        return_arrival_at: offer.return_arrival_at,
        booking_url: offer.booking_url,
        itinerary: offer.itinerary_payload,
        price_disclosure: offer.price_disclosure,
        seat_availability_disclosure: offer.seat_availability_disclosure,
        exchange_rate_disclosure: offer.exchange_rate_disclosure
      }
    end
  end
end
