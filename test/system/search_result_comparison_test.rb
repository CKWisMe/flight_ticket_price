require "application_system_test_case"

class SearchResultComparisonTest < ApplicationSystemTestCase
  test "user can compare results and open booking links" do
    search_request = create_search_request_with_results

    visit search_request_results_path(search_request)

    assert_text "票價列表"
    assert_text "前往購買"
    assert_text "價格與座位供應狀態可能隨售票來源變動"
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
