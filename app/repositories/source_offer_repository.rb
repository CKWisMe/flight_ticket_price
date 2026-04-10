class SourceOfferRepository
  SORT_MAPPING = {
    "price" => :normalized_total_amount,
    "outbound_departure" => :outbound_departure_at,
    "return_departure" => :return_departure_at,
    "total_travel_time" => :total_travel_minutes
  }.freeze

  def upsert_offer!(search_request:, source_key:, offer_attributes:)
    offer = search_request.source_offers.find_or_initialize_by(
      source_key: source_key,
      source_offer_reference: offer_attributes.fetch(:source_offer_reference)
    )
    offer.assign_attributes(offer_attributes.merge(source_key: source_key))
    offer.save!
    offer
  end

  def for_search_request(search_request, sort: "price")
    sort_key = SORT_MAPPING.fetch(sort.to_s, :normalized_total_amount)
    search_request.source_offers.order(sort_key, :outbound_departure_at, :id)
  end

  def recommendation_candidate(search_request)
    search_request.source_offers.order(:normalized_total_amount, :total_travel_minutes, :outbound_departure_at).first
  end
end
