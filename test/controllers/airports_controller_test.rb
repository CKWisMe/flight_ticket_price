require "test_helper"

class AirportsControllerTest < ActionDispatch::IntegrationTest
  SCHEMA_PATH = Rails.root.join("specs/002-airport-lookup-sync/contracts/airport_lookup_response.schema.json")

  setup do
    create_airport(source_identifier: "haneda", iata_code: "HND", icao_code: "RJTT", official_name_en: "Tokyo Haneda Airport", localized_name_zh: "東京羽田機場", city_name: "東京", country_name: "日本", country_code: "JP")
    create_airport(source_identifier: "narita", iata_code: "NRT", icao_code: "RJAA", official_name_en: "Narita International Airport", localized_name_zh: "成田國際機場", city_name: "東京", country_name: "日本", country_code: "JP")
  end

  test "returns lookup json contract" do
    get airports_lookup_path(format: :json), params: { query: "東京" }

    assert_response :success
    schema = JSON.parse(File.read(SCHEMA_PATH))
    payload = JSON.parse(response.body)

    assert_equal "東京", payload["query"]
    assert_equal "東京", payload["normalizedQuery"]
    assert_equal schema.fetch("required").sort, (schema.fetch("required") & payload.keys).sort
    assert_empty(payload.keys - schema.fetch("properties").keys)
    assert_equal 2, payload["matches"].size

    match_schema = schema.dig("properties", "matches", "items")
    first_match = payload["matches"].first
    assert_equal match_schema.fetch("required").sort, (match_schema.fetch("required") & first_match.keys).sort
    assert_empty(first_match.keys - match_schema.fetch("properties").keys)
    assert_includes match_schema.dig("properties", "matchType", "enum"), first_match["matchType"]
    assert_equal true, first_match["selectable"]
  end
end
