require "test_helper"

class AirportLookupPerformanceTest < ActionDispatch::IntegrationTest
  setup do
    sync_seed_airports
  end

  test "lookup endpoint stays within latency budget for repeated requests" do
    durations = []

    5.times do
      started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      get airports_lookup_path(format: :json), params: { query: "東京" }
      durations << Process.clock_gettime(Process::CLOCK_MONOTONIC) - started_at
      assert_response :success
    end

    p95 = durations.sort[(durations.length * 0.95).ceil - 1]
    assert_operator p95, :<, 0.2
  end
end
