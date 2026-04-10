require "test_helper"

class SearchRequestPerformanceTest < ActionDispatch::IntegrationTest
  test "search creation responds quickly enough for queued workflow" do
    started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)

    post search_requests_path, params: {
      tripType: "round_trip",
      originAirportCode: "TPE",
      destinationAirportCode: "NRT",
      directOnly: false,
      departureWindowStartOn: (Date.current + 7.days).iso8601,
      departureWindowEndOn: (Date.current + 14.days).iso8601,
      stayLengthDays: 4,
      displayCurrency: "TWD",
      itineraryLegs: []
    }, as: :json

    elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - started_at

    assert_response :accepted
    assert_operator elapsed, :<, 60
  end
end
