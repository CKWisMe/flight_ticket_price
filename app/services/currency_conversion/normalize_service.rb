module CurrencyConversion
  class NormalizeService
    def self.call(amount:, from_currency:, to_currency:, rates_payload:)
      new(amount:, from_currency:, to_currency:, rates_payload:).call
    end

    def initialize(amount:, from_currency:, to_currency:, rates_payload:)
      @amount = amount.to_d
      @from_currency = from_currency.to_s.upcase
      @to_currency = to_currency.to_s.upcase
      @rates_payload = rates_payload.transform_keys(&:to_s)
    end

    def call
      return amount if from_currency == to_currency

      from_rate = BigDecimal(rates_payload.fetch(from_currency, 1.0).to_s)
      to_rate = BigDecimal(rates_payload.fetch(to_currency, 1.0).to_s)

      ((amount / from_rate) * to_rate).round(2)
    end

    private

    attr_reader :amount, :from_currency, :to_currency, :rates_payload
  end
end
