require "test_helper"

class SourceOfferTest < ActiveSupport::TestCase
  test "normalized total amount must be non-negative" do
    offer = SourceOffer.new(
      id: SecureRandom.uuid,
      search_request: build_search_request,
      source_key: "skyscanner",
      source_offer_reference: "ref-1",
      original_currency: "USD",
      display_currency: "TWD",
      base_fare_amount: 100,
      taxes_and_fees_amount: 20,
      total_amount: 120,
      normalized_total_amount: -1,
      direct_flight: true,
      total_travel_minutes: 180,
      outbound_departure_at: Time.current,
      outbound_arrival_at: 3.hours.from_now,
      itinerary_payload: [ { leg: 1 } ],
      booking_url: "https://example.com",
      fetched_at: Time.current
    )

    assert_not offer.valid?
    assert_includes offer.errors[:normalized_total_amount], "must be greater than or equal to 0"
  end

  private

  def build_search_request
    SearchRequest.new(
      id: SecureRandom.uuid,
      trip_type: "round_trip",
      origin_airport_code: "TPE",
      destination_airport_code: "NRT",
      direct_only: false,
      departure_window_start_on: Date.current + 7.days,
      departure_window_end_on: Date.current + 14.days,
      stay_length_days: 4,
      display_currency: "TWD",
      status: "queued",
      requested_at: Time.current
    )
  end
end
