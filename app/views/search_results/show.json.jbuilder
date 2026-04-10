json.searchRequestId @results_payload[:search_request_id]
json.status @results_payload[:status]
json.displayCurrency @results_payload[:display_currency]
json.recommendation do
  if @results_payload[:recommendation]
    json.offerId @results_payload[:recommendation][:offer_id]
    json.reasonCode @results_payload[:recommendation][:reason_code]
    json.explanation @results_payload[:recommendation][:explanation]
  end
end
json.sourceStatuses @results_payload[:source_statuses] do |source_status|
  json.sourceKey source_status[:source_key]
  json.status source_status[:status]
  json.errorCode source_status[:error_code]
  json.fetchedAt source_status[:fetched_at]
end
json.offers @results_payload[:offers] do |offer|
  json.offerId offer[:offer_id]
  json.sourceKey offer[:source_key]
  json.originalCurrency offer[:original_currency]
  json.displayCurrency offer[:display_currency]
  json.totalAmount offer[:total_amount]
  json.normalizedTotalAmount offer[:normalized_total_amount]
  json.directFlight offer[:direct_flight]
  json.totalTravelMinutes offer[:total_travel_minutes]
  json.outboundDepartureAt offer[:outbound_departure_at]
  json.outboundArrivalAt offer[:outbound_arrival_at]
  json.returnDepartureAt offer[:return_departure_at]
  json.returnArrivalAt offer[:return_arrival_at]
  json.bookingUrl offer[:booking_url]
  json.itinerary offer[:itinerary]
  json.priceDisclosure offer[:price_disclosure]
  json.seatAvailabilityDisclosure offer[:seat_availability_disclosure]
  json.exchangeRateDisclosure offer[:exchange_rate_disclosure]
end
