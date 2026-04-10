require "test_helper"

class SearchRequestTest < ActiveSupport::TestCase
  test "round trip requires origin and destination" do
    request = SearchRequest.new(
      trip_type: "round_trip",
      direct_only: false,
      departure_window_start_on: Date.current + 7.days,
      departure_window_end_on: Date.current + 12.days,
      stay_length_days: 3,
      display_currency: "TWD"
    )

    assert_not request.valid?
    assert_includes request.errors[:origin_airport_code], "不能空白"
    assert_includes request.errors[:destination_airport_code], "不能空白"
  end

  test "multi city requires between two and four itinerary legs" do
    request = SearchRequest.new(
      trip_type: "multi_city",
      direct_only: false,
      departure_window_start_on: Date.current + 7.days,
      departure_window_end_on: Date.current + 12.days,
      stay_length_days: 3,
      display_currency: "TWD"
    )
    request.itinerary_legs.build(position: 1, origin_airport_code: "TPE", destination_airport_code: "KIX")

    assert_not request.valid?
    assert_includes request.errors[:itinerary_legs], "多點進出需填寫 2 到 4 段航程"
  end
end
