require "test_helper"

class SearchRequests::CreateServiceTest < ActiveSupport::TestCase
  test "creates search request and enqueues ticket search job" do
    create_airport(iata_code: "TPE", icao_code: "RCTP")
    create_airport(source_identifier: "test:nrt", iata_code: "NRT", icao_code: "RJAA", official_name_en: "Narita International Airport", localized_name_zh: "成田國際機場", city_name: "東京", country_name: "日本", country_code: "JP")

    assert_enqueued_with(job: TicketSearchJob) do
      result = SearchRequests::CreateService.call(params: {
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

      assert result.success?
      assert_equal "queued", result.search_request.status
    end
  end

  test "returns validation error when airport code is not from active directory" do
    result = SearchRequests::CreateService.call(params: {
      trip_type: "round_trip",
      origin_airport_code: "XXX",
      destination_airport_code: "YYY",
      direct_only: false,
      departure_window_start_on: Date.current + 7.days,
      departure_window_end_on: Date.current + 14.days,
      stay_length_days: 4,
      display_currency: "TWD",
      itinerary_legs: []
    })

    assert_not result.success?
    assert_includes result.errors.map { |error| error[:field] }, :origin_airport_code
    assert_includes result.errors.map { |error| error[:field] }, :destination_airport_code
  end
end
