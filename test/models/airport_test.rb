require "test_helper"

class AirportTest < ActiveSupport::TestCase
  test "normalizes lookup fields before validation" do
    airport = create_airport(
      iata_code: " tpe ",
      icao_code: " rctp ",
      official_name_en: "Taiwan Taoyuan International Airport",
      localized_name_zh: "台灣桃園國際機場",
      city_name: " 桃園 "
    )

    assert_equal "TPE", airport.iata_code
    assert_equal "rctp", airport.normalized_icao_code
    assert_equal "桃園", airport.normalized_city_name
  end

  test "requires unique source identifier" do
    create_airport(source_identifier: "duplicate")
    duplicate = Airport.new(
      id: SecureRandom.uuid,
      source_identifier: "duplicate",
      official_name_en: "Another Airport",
      city_name: "東京",
      country_name: "日本",
      last_synced_at: Time.current,
      active: true
    )

    assert_not duplicate.valid?
  end
end
