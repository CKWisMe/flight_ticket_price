require "test_helper"

class SearchRequests::RecommendationServiceTest < ActiveSupport::TestCase
  test "picks cheapest offer then shortest duration" do
    search_request = SearchRequest.create!(
      trip_type: "round_trip",
      origin_airport_code: "TPE",
      destination_airport_code: "NRT",
      direct_only: false,
      departure_window_start_on: Date.current + 7.days,
      departure_window_end_on: Date.current + 14.days,
      stay_length_days: 4,
      display_currency: "TWD",
      status: "completed",
      requested_at: Time.current
    )
    search_request.source_offers.create!(
      source_key: "skyscanner",
      source_offer_reference: "a",
      original_currency: "TWD",
      display_currency: "TWD",
      base_fare_amount: 100,
      taxes_and_fees_amount: 20,
      total_amount: 120,
      normalized_total_amount: 120,
      direct_flight: true,
      total_travel_minutes: 200,
      outbound_departure_at: 2.days.from_now,
      outbound_arrival_at: 2.days.from_now + 3.hours,
      itinerary_payload: [ { leg: 1 } ],
      booking_url: "https://example.com/a",
      fetched_at: Time.current,
      price_disclosure: "price",
      seat_availability_disclosure: "seat",
      exchange_rate_disclosure: "fx"
    )
    best_offer = search_request.source_offers.create!(
      source_key: "trip_com",
      source_offer_reference: "b",
      original_currency: "TWD",
      display_currency: "TWD",
      base_fare_amount: 100,
      taxes_and_fees_amount: 20,
      total_amount: 120,
      normalized_total_amount: 120,
      direct_flight: true,
      total_travel_minutes: 180,
      outbound_departure_at: 1.day.from_now,
      outbound_arrival_at: 1.day.from_now + 3.hours,
      itinerary_payload: [ { leg: 1 } ],
      booking_url: "https://example.com/b",
      fetched_at: Time.current,
      price_disclosure: "price",
      seat_availability_disclosure: "seat",
      exchange_rate_disclosure: "fx"
    )

    recommendation = SearchRequests::RecommendationService.new(search_request:).call

    assert_equal best_offer, recommendation.source_offer
  end
end
