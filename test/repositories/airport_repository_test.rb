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
end
