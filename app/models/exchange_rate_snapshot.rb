class ExchangeRateSnapshot < ApplicationRecord
  include UuidPrimaryKey

  belongs_to :search_request

  validates :base_currency, :provider_key, :captured_at, presence: true
  validates :rates_payload, presence: true
end
