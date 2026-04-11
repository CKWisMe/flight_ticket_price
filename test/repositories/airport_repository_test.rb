require "test_helper"

class AirportRepositoryTest < ActiveSupport::TestCase
  test "searches active airports by prefix and ignores inactive ones" do
    create_airport(iata_code: "TPE", city_name: "桃園")
    create_airport(source_identifier: "inactive", iata_code: "TPX", city_name: "台北", active: false)

    matches = AirportRepository.new.search_active(query: "tp", limit: 10)

    assert_equal [ "TPE" ], matches.map(&:iata_code)
  end

  test "deactivates airports missing from complete snapshot" do
    keep = create_airport(source_identifier: "keep")
    drop = create_airport(source_identifier: "drop", iata_code: "KHH", icao_code: "RCKH", city_name: "高雄")

    deactivated = AirportRepository.new.deactivate_missing!(source_identifiers: [ keep.source_identifier ], synced_at: Time.current)

    assert_equal 1, deactivated
    assert_predicate keep.reload, :active?
    assert_not drop.reload.active?
  end

  test "bulk upserts airports from source data" do
    existing = create_airport(source_identifier: "seed:TPE", iata_code: "TPE", icao_code: "RCTP", official_name_en: "Old Name", city_name: "Old City", country_name: "Old Country", country_code: "TW")
    synced_at = Time.current

    count = AirportRepository.new.bulk_upsert_from_source!(
      synced_at: synced_at,
      records: [
        {
          "sourceIdentifier" => "seed:TPE",
          "iataCode" => "TPE",
          "icaoCode" => "RCTP",
          "officialNameEn" => "Taiwan Taoyuan International Airport",
          "localizedNameZh" => "台灣桃園國際機場",
          "cityName" => "桃園",
          "countryName" => "台灣",
          "countryCode" => "TW"
        },
        {
          "sourceIdentifier" => "seed:NRT",
          "iataCode" => "NRT",
          "icaoCode" => "RJAA",
          "officialNameEn" => "Narita International Airport",
          "localizedNameZh" => "成田國際機場",
          "cityName" => "東京",
          "countryName" => "日本",
          "countryCode" => "JP"
        }
      ]
    )

    assert_equal 2, count
    assert_equal 2, Airport.count
    assert_equal existing.id, Airport.find_by!(source_identifier: "seed:TPE").id
    assert_equal "桃園", Airport.find_by!(source_identifier: "seed:TPE").city_name
    assert_equal "NRT", Airport.find_by!(source_identifier: "seed:NRT").iata_code
  end
end
