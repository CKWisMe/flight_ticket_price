require "test_helper"

class SearchResultsControllerTest < ActionDispatch::IntegrationTest
  setup do
    create_airport(iata_code: "TPE", icao_code: "RCTP")
    create_airport(source_identifier: "test:nrt", iata_code: "NRT", icao_code: "RJAA", official_name_en: "Narita International Airport", localized_name_zh: "成田國際機場", city_name: "東京", country_name: "日本", country_code: "JP")
  end

  test "returns sorted results with disclosures and booking url" do
    search_request = nil

    perform_enqueued_jobs do
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
      search_request = SearchRequest.last
    end

    get search_request_results_path(search_request), params: { sort: "price" }, as: :json

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal "TWD", payload["displayCurrency"]
    assert payload["offers"].first["bookingUrl"].present?
    assert payload["offers"].first["priceDisclosure"].present?
  end
end
