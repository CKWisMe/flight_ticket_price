require "test_helper"

class RecommendationTest < ActiveSupport::TestCase
  test "requires explanation" do
    recommendation = Recommendation.new(reason_code: "lowest_total_price", ranked_at: Time.current)

    assert_not recommendation.valid?
    assert recommendation.errors.added?(:explanation, :blank)
  end
end
