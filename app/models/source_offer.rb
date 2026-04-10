class SourceOffer < ApplicationRecord
  include UuidPrimaryKey

  belongs_to :search_request
  has_one :recommendation, dependent: :destroy

  validates :source_key, :source_offer_reference, :original_currency, :display_currency, :booking_url, :fetched_at, presence: true
  validates :base_fare_amount, :taxes_and_fees_amount, :total_amount, :normalized_total_amount, numericality: { greater_than_or_equal_to: 0 }
  validates :total_travel_minutes, numericality: { only_integer: true, greater_than: 0 }
  validates :direct_flight, inclusion: { in: [ true, false ] }
  validates :itinerary_payload, presence: true
end
