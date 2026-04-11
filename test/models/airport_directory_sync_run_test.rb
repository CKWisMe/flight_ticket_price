require "test_helper"

class AirportDirectorySyncRunTest < ActiveSupport::TestCase
  test "requires completed_at when sync succeeded" do
    run = AirportDirectorySyncRun.new(
      source_key: "primary",
      status: "succeeded",
      started_at: Time.current,
      fetched_record_count: 1,
      upserted_record_count: 1,
      deactivated_record_count: 0,
      failed_record_count: 0
    )

    assert_not run.valid?
    assert_includes run.errors[:completed_at], "不能空白"
  end
end
