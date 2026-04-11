require "application_system_test_case"

class SearchResultComparisonTest < ApplicationSystemTestCase
  setup do
    create_airport(iata_code: "TPE", icao_code: "RCTP")
    create_airport(source_identifier: "nrt", iata_code: "NRT", icao_code: "RJAA", official_name_en: "Narita International Airport", localized_name_zh: "成田國際機場", city_name: "東京", country_name: "日本", country_code: "JP")
  end

  test "user can compare results and open booking links" do
    search_request = create_search_request_with_results

    visit search_request_results_path(search_request)

    assert_text "Offer Comparison"
    assert_text "Open Booking"
    assert_text "Compare price, schedule, and disclosures before opening the provider booking page."
  end

  private

  def create_search_request_with_results
    perform_enqueued_jobs do
      SearchRequests::CreateService.call(params: {
        trip_type: "round_trip",
        origin_airport_code: "TPE",
        destination_airport_code: "NRT",
        direct_only: false,
        departure_window_start_on: Date.current + 7.days,
        departure_window_end_on: Date.current + 14.days,
        stay_length_days: 4,
        display_currency: "TWD",
        itinerary_legs: []
      })
    end
    SearchRequest.last
  end
end
