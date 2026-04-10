require "test_helper"

class RecommendationTest < ActiveSupport::TestCase
  test "requires explanation" do
    recommendation = Recommendation.new(reason_code: "lowest_total_price", ranked_at: Time.current)

    assert_not recommendation.valid?
    assert_includes recommendation.errors[:explanation], "can't be blank"
  end
end
