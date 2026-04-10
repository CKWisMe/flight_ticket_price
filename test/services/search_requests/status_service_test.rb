require "test_helper"

class SearchRequests::StatusServiceTest < ActiveSupport::TestCase
  test "returns sorted results payload" do
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
    search_request.source_statuses.create!(source_key: "skyscanner", status: "succeeded")
    search_request.source_offers.create!(
      source_key: "skyscanner",
      source_offer_reference: "ref",
      original_currency: "TWD",
      display_currency: "TWD",
      base_fare_amount: 100,
      taxes_and_fees_amount: 20,
      total_amount: 120,
      normalized_total_amount: 120,
      direct_flight: true,
      total_travel_minutes: 180,
      outbound_departure_at: Time.current,
      outbound_arrival_at: 3.hours.from_now,
      itinerary_payload: [{ leg: 1 }],
      booking_url: "https://example.com",
      fetched_at: Time.current,
      price_disclosure: "price",
      seat_availability_disclosure: "seat",
      exchange_rate_disclosure: "fx"
    )

    payload = SearchRequests::StatusService.new(search_request:).results_payload

    assert_equal "completed", payload[:status]
    assert_equal 1, payload[:offers].size
  end
end
