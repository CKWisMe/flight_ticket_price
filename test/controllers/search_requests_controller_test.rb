require "test_helper"

class SearchRequestsControllerTest < ActionDispatch::IntegrationTest
  setup do
    create_airport(iata_code: "TPE", icao_code: "RCTP")
    create_airport(source_identifier: "test:nrt", iata_code: "NRT", icao_code: "RJAA", official_name_en: "Narita International Airport", localized_name_zh: "成田國際機場", city_name: "東京", country_name: "日本", country_code: "JP")
  end

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
      originAirportCode: "AAA",
      destinationAirportCode: "BBB",
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
end
