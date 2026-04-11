require "test_helper"

class AirportDirectorySyncAvailabilityTest < ActionDispatch::IntegrationTest
  test "lookup uses synced airport directory data" do
    sync_seed_airports

    get airports_lookup_path(format: :json), params: { query: "東京" }

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal %w[HND NRT], payload["matches"].first(2).map { |match| match["airportCode"] }
  end
end
