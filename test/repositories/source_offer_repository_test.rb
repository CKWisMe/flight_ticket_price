require "test_helper"

class SourceOfferRepositoryTest < ActiveSupport::TestCase
  setup do
    @search_request = SearchRequest.create!(
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
    @repository = SourceOfferRepository.new
  end

  test "sorts by normalized total amount by default" do
    create_offer!("a", 200, 200.minutes)
    create_offer!("b", 100, 180.minutes)

    assert_equal %w[b a], @repository.for_search_request(@search_request).pluck(:source_offer_reference)
  end

  test "returns best recommendation candidate using price then duration" do
    create_offer!("a", 100, 220.minutes)
    create_offer!("b", 100, 180.minutes)

    assert_equal "b", @repository.recommendation_candidate(@search_request).source_offer_reference
  end

  private

  def create_offer!(reference, amount, duration)
    @repository.upsert_offer!(
      search_request: @search_request,
      source_key: "skyscanner",
      offer_attributes: {
        source_offer_reference: reference,
        original_currency: "TWD",
        display_currency: "TWD",
        base_fare_amount: amount - 20,
        taxes_and_fees_amount: 20,
        total_amount: amount,
        normalized_total_amount: amount,
        direct_flight: true,
        total_travel_minutes: duration.to_i / 60,
        outbound_departure_at: Time.current,
        outbound_arrival_at: 2.hours.from_now,
        return_departure_at: 3.days.from_now,
        return_arrival_at: 3.days.from_now + 2.hours,
        itinerary_payload: [ { leg: 1 } ],
        booking_url: "https://example.com/#{reference}",
        fetched_at: Time.current,
        stale_at: 30.minutes.from_now,
        price_disclosure: "price",
        seat_availability_disclosure: "seat",
        exchange_rate_disclosure: "fx"
      }
    )
  end
end
