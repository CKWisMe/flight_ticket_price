require "application_system_test_case"

class SearchRequestSubmissionTest < ApplicationSystemTestCase
  setup do
    create_airport(iata_code: "TPE", icao_code: "RCTP")
    create_airport(source_identifier: "nrt", iata_code: "NRT", icao_code: "RJAA", official_name_en: "Narita International Airport", localized_name_zh: "成田國際機場", city_name: "東京", country_name: "日本", country_code: "JP")
  end

  test "user submits a search request and sees status page" do
    visit root_path

    select "來回", from: "旅程類型"
    fill_in "出發機場", with: "TPE"
    find("input[name='search_request[origin_airport_code]']", visible: false).set("TPE")
    fill_in "目的地機場", with: "NRT"
    find("input[name='search_request[destination_airport_code]']", visible: false).set("NRT")
    fill_in "旅遊天數", with: 4
    select "TWD", from: "顯示幣別"

    click_button "開始搜尋票價"

    assert_text "搜尋請求已送出，票價結果正在準備中。"
    assert_text "搜尋狀態"
    assert_text "已完成"
  end

  test "user can return home from results with consistent zh-TW cta labels" do
    search_request = create_search_request_with_results

    visit root_path
    assert_button "開始搜尋票價"

    visit search_request_results_path(search_request)

    assert_link "回到首頁"
    click_link "回到首頁"

    assert_current_path root_path
    assert_button "開始搜尋票價"
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
