require "test_helper"

class SourceFetchJobTest < ActiveJob::TestCase
  test "creates normalized offers and refreshes recommendation" do
    search_request = SearchRequest.create!(
      trip_type: "round_trip",
      origin_airport_code: "TPE",
      destination_airport_code: "NRT",
      direct_only: false,
      departure_window_start_on: Date.current + 7.days,
      departure_window_end_on: Date.current + 14.days,
      stay_length_days: 4,
      display_currency: "TWD",
      status: "running",
      requested_at: Time.current
    )
    search_request.source_statuses.create!(source_key: "skyscanner", status: "pending")
    search_request.create_exchange_rate_snapshot!(base_currency: "TWD", rates_payload: { "USD" => 0.032, "TWD" => 1.0 }, provider_key: "static_default", captured_at: Time.current)

    SourceFetchJob.perform_now(search_request.id, "skyscanner")

    assert_equal "succeeded", search_request.source_statuses.find_by(source_key: "skyscanner").status
    assert_operator search_request.source_offers.count, :>=, 1
    assert search_request.reload.recommendation.present?
  end
end
