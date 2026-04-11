require "test_helper"

class AirportDirectorySyncStatusesControllerTest < ActionDispatch::IntegrationTest
  SCHEMA_PATH = Rails.root.join("specs/002-airport-lookup-sync/contracts/airport_directory_sync_status_response.schema.json")

  test "returns latest sync status payload" do
    sync_seed_airports

    get airport_directory_sync_status_path(format: :json)

    assert_response :success
    schema = JSON.parse(File.read(SCHEMA_PATH))
    payload = JSON.parse(response.body)

    assert_equal schema.fetch("required").sort, (schema.fetch("required") & payload.keys).sort
    assert_empty(payload.keys - schema.fetch("properties").keys)
    assert_equal "primary", payload["sourceKey"]
    assert_includes schema.dig("properties", "status", "enum"), payload["status"]
    assert_operator payload["fetchedRecordCount"], :>=, 0
    assert_operator payload["upsertedRecordCount"], :>=, 0
    assert_operator payload["deactivatedRecordCount"], :>=, 0
    assert_operator payload["failedRecordCount"], :>=, 0
  end
end
