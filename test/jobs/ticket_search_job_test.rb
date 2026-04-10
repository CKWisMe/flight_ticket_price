require "test_helper"

class TicketSearchJobTest < ActiveJob::TestCase
  test "moves search request to running and enqueues source jobs" do
    search_request = SearchRequest.create!(
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
    search_request.source_statuses.create!(source_key: "skyscanner", status: "pending")
    search_request.source_statuses.create!(source_key: "trip_com", status: "pending")

    assert_enqueued_jobs 2, only: SourceFetchJob do
      TicketSearchJob.perform_now(search_request.id)
    end

    assert_equal "running", search_request.reload.status
  end
end
