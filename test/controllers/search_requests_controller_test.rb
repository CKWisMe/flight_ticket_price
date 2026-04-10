require "test_helper"

class SearchRequestsControllerTest < ActionDispatch::IntegrationTest
  test "creates search request and returns accepted json" do
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

    assert_response :accepted
    payload = JSON.parse(response.body)
    assert_equal "queued", payload["status"]
    assert payload["searchRequestId"].present?
  end

  test "returns validation errors for invalid request" do
    post search_requests_path, params: {
      tripType: "round_trip",
      directOnly: false,
      departureWindowStartOn: (Date.current + 7.days).iso8601,
      departureWindowEndOn: (Date.current + 8.days).iso8601,
      stayLengthDays: 4,
      displayCurrency: "TWD"
    }, as: :json

    assert_response :unprocessable_entity
    payload = JSON.parse(response.body)
    assert payload["errors"].any?
  end

  test "rejects multi city requests with more than four itinerary legs" do
    post search_requests_path, params: {
      tripType: "multi_city",
      directOnly: false,
      departureWindowStartOn: (Date.current + 7.days).iso8601,
      departureWindowEndOn: (Date.current + 14.days).iso8601,
      stayLengthDays: 4,
      displayCurrency: "TWD",
      itineraryLegs: [
        { position: 1, originAirportCode: "TPE", destinationAirportCode: "KIX" },
        { position: 2, originAirportCode: "KIX", destinationAirportCode: "ICN" },
        { position: 3, originAirportCode: "ICN", destinationAirportCode: "SIN" },
        { position: 4, originAirportCode: "SIN", destinationAirportCode: "BKK" },
        { position: 5, originAirportCode: "BKK", destinationAirportCode: "TPE" }
      ]
    }, as: :json

    assert_response :unprocessable_entity
    payload = JSON.parse(response.body)
    assert payload["errors"].any? { |error| error["field"] == "itinerary_legs" }
  end
end
