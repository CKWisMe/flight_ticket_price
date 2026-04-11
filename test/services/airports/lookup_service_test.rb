require "test_helper"

class Airports::LookupServiceTest < ActiveSupport::TestCase
  setup do
    create_airport(iata_code: "TPE", icao_code: "RCTP", city_name: "桃園", localized_name_zh: "台灣桃園國際機場")
    create_airport(source_identifier: "haneda", iata_code: "HND", icao_code: "RJTT", official_name_en: "Tokyo Haneda Airport", localized_name_zh: "東京羽田機場", city_name: "東京", country_name: "日本", country_code: "JP")
    create_airport(source_identifier: "narita", iata_code: "NRT", icao_code: "RJAA", official_name_en: "Narita International Airport", localized_name_zh: "成田國際機場", city_name: "東京", country_name: "日本", country_code: "JP")
    create_airport(source_identifier: "lhr", iata_code: "LHR", icao_code: "EGLL", official_name_en: "Heathrow Airport", localized_name_zh: "倫敦希斯洛機場", city_name: "倫敦", country_name: "英國", country_code: "GB")
    create_airport(source_identifier: "lgw", iata_code: "LGW", icao_code: "EGKK", official_name_en: "Gatwick Airport", localized_name_zh: "倫敦蓋威克機場", city_name: "倫敦", country_name: "英國", country_code: "GB")
  end

  test "returns match by airport code" do
    result = Airports::LookupService.new(query: "TPE").call

    assert_equal "tpe", result.normalized_query
    assert_equal "TPE", result.matches.first[:airport_code]
    assert_equal "iata_code", result.matches.first[:match_type]
  end

  test "returns match by localized name" do
    result = Airports::LookupService.new(query: "台灣").call

    assert_equal "localized_name_zh", result.matches.first[:match_type]
  end

  test "returns multiple airports for city query" do
    result = Airports::LookupService.new(query: "東京").call

    assert_equal 2, result.matches.size
    assert_equal %w[HND NRT], result.matches.map { |match| match[:airport_code] }
  end

  test "supports country hint ordering" do
    create_airport(source_identifier: "london-ca", iata_code: "YXU", icao_code: "CYXU", official_name_en: "London International Airport", localized_name_zh: "倫敦國際機場", city_name: "倫敦", country_name: "加拿大", country_code: "CA")

    result = Airports::LookupService.new(query: "倫敦 加拿大").call

    assert_equal "YXU", result.matches.first[:airport_code]
  end
end
