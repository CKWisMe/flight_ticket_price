class ExchangeRateRepository
  DEFAULT_RATES = {
    "TWD" => 1.0,
    "USD" => 0.032,
    "JPY" => 4.8
  }.freeze

  def fetch_rates(base_currency:)
    base_currency = base_currency.to_s.upcase
    rates = DEFAULT_RATES

    converted =
      if base_currency == "TWD"
        rates
      else
        base_to_twd = rates.fetch(base_currency, 1.0)
        rates.transform_values { |value| (value.to_d / base_to_twd.to_d).to_f.round(6) }
      end

    [ converted, "static_default" ]
  end
end
