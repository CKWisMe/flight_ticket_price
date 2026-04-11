require "test_helper"
require "uri"

module SourceAdapters
  class SkyscannerAdapterTest < ActiveSupport::TestCase
    test "builds a day view booking URL from the search request" do
      search_request = SearchRequest.create!(
        trip_type: "round_trip",
        origin_airport_code: "TPE",
        destination_airport_code: "NRT",
        direct_only: true,
        departure_window_start_on: Date.new(2026, 5, 1),
        departure_window_end_on: Date.new(2026, 5, 10),
        stay_length_days: 4,
        display_currency: "TWD",
        status: "queued",
        requested_at: Time.current
      )

      booking_url = SkyscannerAdapter.new(search_request:).fetch.first.fetch(:booking_url)
      uri = URI.parse(booking_url)
      query = Rack::Utils.parse_nested_query(uri.query)

      assert_equal "/g/referrals/v1/flights/day-view", uri.path
      assert_equal "TPE", query["origin"]
      assert_equal "NRT", query["destination"]
      assert_equal "2026-05-01", query["outboundDate"]
      assert_equal "2026-05-05", query["inboundDate"]
      assert_equal "true", query["preferDirects"]
      assert_equal "TWD", query["currency"]
      assert_equal "TW", query["market"]
      assert_equal "zh-TW", query["locale"]
      assert_equal "1", query["adultsv2"]
      assert_equal "economy", query["cabinclass"]
    end

    test "builds a multi-city booking URL from itinerary legs" do
      search_request = SearchRequest.create!(
        trip_type: "multi_city",
        direct_only: false,
        departure_window_start_on: Date.new(2026, 6, 1),
        departure_window_end_on: Date.new(2026, 6, 20),
        stay_length_days: 3,
        display_currency: "JPY",
        status: "queued",
        requested_at: Time.current,
        itinerary_legs_attributes: [
          {
            position: 1,
            origin_airport_code: "TPE",
            destination_airport_code: "KIX",
            departure_on: Date.new(2026, 6, 1)
          },
          {
            position: 2,
            origin_airport_code: "KIX",
            destination_airport_code: "CTS",
            departure_on: Date.new(2026, 6, 5)
          }
        ]
      )

      booking_url = SkyscannerAdapter.new(search_request:).fetch.first.fetch(:booking_url)
      uri = URI.parse(booking_url)
      query = Rack::Utils.parse_nested_query(uri.query)

      assert_equal "/g/referrals/v1/flights/multicity", uri.path
      assert_equal "TPE", query["origin0"]
      assert_equal "KIX", query["destination0"]
      assert_equal "2026-06-01", query["date0"]
      assert_equal "KIX", query["origin1"]
      assert_equal "CTS", query["destination1"]
      assert_equal "2026-06-05", query["date1"]
      assert_equal "JPY", query["currency"]
      assert_equal "JP", query["market"]
      assert_equal "ja-JP", query["locale"]
      assert_equal "1", query["adultsv2"]
      assert_equal "economy", query["cabinclass"]
    end
  end
end
