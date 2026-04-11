require "test_helper"

class AirportDirectorySources::OurAirportsAdapterTest < ActiveSupport::TestCase
  test "builds a complete snapshot from ourairports csv data" do
    adapter = AirportDirectorySources::OurAirportsAdapter.new(
      settings: {
        "key" => "primary",
        "complete_snapshot" => true,
        "airports_url" => "https://example.test/airports.csv",
        "countries_url" => "https://example.test/countries.csv"
      },
      http_get: lambda do |url|
        case url
        when "https://example.test/airports.csv"
          <<~CSV
            id,ident,type,name,municipality,iso_country,gps_code,iata_code,keywords
            1,KAAA,small_airport,Alpha Airport,Alpha City,US,KAAA,AAA,"Alpha Field,阿爾法機場,阿爾法市"
            2,KBBB,closed_airport,Closed Airport,Beta City,US,KBBB,BBB,
            3,XX,small_airport,No Code Airport,Gamma City,US,,,"無代碼機場"
            4,RJTT,large_airport,Tokyo Haneda Airport,Tokyo,JP,RJTT,HND,"東京羽田機場,東京國際機場,東京"
          CSV
        when "https://example.test/countries.csv"
          <<~CSV
            code,name,keywords
            US,United States,"美國,美利堅合眾國"
            JP,Japan,"日本,日本國"
          CSV
        else
          raise "unexpected url: #{url}"
        end
      end,
      clock: -> { Time.utc(2026, 4, 11, 1, 0, 0) }
    )

    snapshot = adapter.fetch_snapshot

    assert_equal "primary", snapshot["sourceKey"]
    assert_equal "2026-04-11T01:00:00Z", snapshot["snapshotVersion"]
    assert_equal true, snapshot["completeSnapshot"]
    assert_equal 2, snapshot["records"].size

    assert_equal(
      {
        "sourceIdentifier" => "our_airports:1",
        "iataCode" => "AAA",
        "icaoCode" => "KAAA",
        "officialNameEn" => "Alpha Airport",
        "localizedNameZh" => "\u963f\u723e\u6cd5\u6a5f\u5834",
        "cityName" => "\u963f\u723e\u6cd5\u5e02",
        "countryName" => "\u7f8e\u570b",
        "countryCode" => "US"
      },
      snapshot["records"].first
    )

    assert_equal "HND", snapshot["records"].last["iataCode"]
    assert_equal "\u6771\u4eac\u7fbd\u7530\u6a5f\u5834", snapshot["records"].last["localizedNameZh"]
    assert_equal "\u6771\u4eac", snapshot["records"].last["cityName"]
    assert_equal "\u65e5\u672c", snapshot["records"].last["countryName"]
  end
end
