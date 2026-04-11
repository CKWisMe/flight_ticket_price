require "test_helper"

class SearchRequestPerformanceTest < ActionDispatch::IntegrationTest
  setup do
    create_airport(iata_code: "TPE", icao_code: "RCTP")
    create_airport(source_identifier: "test:nrt", iata_code: "NRT", icao_code: "RJAA", official_name_en: "Narita International Airport", localized_name_zh: "成田國際機場", city_name: "東京", country_name: "日本", country_code: "JP")
  end

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
