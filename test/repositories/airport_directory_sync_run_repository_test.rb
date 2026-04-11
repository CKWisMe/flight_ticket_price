require "test_helper"

class AirportDirectorySyncRunRepositoryTest < ActiveSupport::TestCase
  test "starts and finishes sync run" do
    repository = AirportDirectorySyncRunRepository.new
    run = repository.start!(source_key: "primary", source_snapshot_version: "v1", started_at: Time.current)

    repository.finish!(
      run: run,
      status: "succeeded",
      completed_at: Time.current,
      fetched_record_count: 2,
      upserted_record_count: 2,
      deactivated_record_count: 0,
      failed_record_count: 0
    )

    assert_equal "succeeded", run.reload.status
    assert_equal run, repository.latest
  end
end
