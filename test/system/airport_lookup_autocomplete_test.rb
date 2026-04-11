require "application_system_test_case"

class AirportLookupAutocompleteTest < ApplicationSystemTestCase
  setup do
    create_airport(iata_code: "TPE", icao_code: "RCTP")
    create_airport(source_identifier: "nrt", iata_code: "NRT", icao_code: "RJAA", official_name_en: "Narita International Airport", localized_name_zh: "成田國際機場", city_name: "東京", country_name: "日本", country_code: "JP")
  end

  test "user submits a search request after selecting airports" do
    visit root_path

    fill_in "Origin Airport", with: "Taiwan Taoyuan International Airport"
    find("input[name='search_request[origin_airport_code]']", visible: false).set("TPE")
    fill_in "Destination Airport", with: "Narita International Airport"
    find("input[name='search_request[destination_airport_code]']", visible: false).set("NRT")
    fill_in "Trip Length (days)", with: 4
    select "TWD", from: "Display Currency"

    click_button "Search Fares"

    assert_text "Request Status"
    assert_text "completed"
  end
end
