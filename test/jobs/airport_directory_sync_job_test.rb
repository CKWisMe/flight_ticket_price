require "test_helper"

class AirportDirectorySyncJobTest < ActiveJob::TestCase
  test "creates latest sync run from configured source" do
    assert_difference -> { AirportDirectorySyncRun.count }, +1 do
      AirportDirectorySyncJob.perform_now
    end

    assert Airport.count.positive?
  end
end
