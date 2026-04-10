require "test_helper"

class CurrencyConversion::NormalizeServiceTest < ActiveSupport::TestCase
  test "converts amount using rates payload" do
    normalized = CurrencyConversion::NormalizeService.call(
      amount: 100,
      from_currency: "USD",
      to_currency: "TWD",
      rates_payload: { "USD" => 0.032, "TWD" => 1.0 }
    )

    assert_equal 3125.0, normalized.to_f
  end
end
