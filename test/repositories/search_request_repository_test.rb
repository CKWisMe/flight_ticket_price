require "test_helper"

class SearchRequestRepositoryTest < ActiveSupport::TestCase
  test "create creates request, statuses and exchange rate snapshot" do
    repository = SearchRequestRepository.new

    request = repository.create!(
      attributes: {
        trip_type: "round_trip",
        origin_airport_code: "TPE",
        destination_airport_code: "NRT",
        direct_only: false,
        departure_window_start_on: Date.current + 7.days,
        departure_window_end_on: Date.current + 14.days,
        stay_length_days: 4,
        display_currency: "TWD",
        status: "queued"
      },
      itinerary_legs: [],
      source_keys: %w[skyscanner trip_com],
      rates_payload: { "TWD" => 1.0, "USD" => 0.03 },
      provider_key: "static_default"
    )

    assert_equal 2, request.source_statuses.count
    assert_equal "TWD", request.exchange_rate_snapshot.base_currency
  end
end
