require "application_system_test_case"

class AirportLookupCityDisambiguationTest < ApplicationSystemTestCase
  setup do
    create_airport(source_identifier: "haneda", iata_code: "HND", icao_code: "RJTT", official_name_en: "Tokyo Haneda Airport", localized_name_zh: "東京羽田機場", city_name: "東京", country_name: "日本", country_code: "JP")
    create_airport(source_identifier: "narita", iata_code: "NRT", icao_code: "RJAA", official_name_en: "Narita International Airport", localized_name_zh: "成田國際機場", city_name: "東京", country_name: "日本", country_code: "JP")
    create_airport(source_identifier: "tpe", iata_code: "TPE", icao_code: "RCTP", official_name_en: "Taiwan Taoyuan International Airport", localized_name_zh: "台灣桃園國際機場", city_name: "桃園", country_name: "台灣", country_code: "TW")
  end

  test "city with multiple airports still requires an explicit airport selection before submit" do
    visit root_path

    fill_in "出發機場", with: "Taiwan Taoyuan International Airport"
    find("input[name='search_request[origin_airport_code]']", visible: false).set("TPE")

    fill_in "目的地機場", with: "Tokyo"
    find("input[name='search_request[destination_airport_code]']", visible: false).set("HND")

    fill_in "旅遊天數", with: 4
    select "TWD", from: "顯示幣別"
    click_button "開始搜尋票價"

    assert_text "搜尋狀態"
    assert_text "查看結果"
  end
end
