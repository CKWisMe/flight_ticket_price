class ItineraryLeg < ApplicationRecord
  include UuidPrimaryKey

  belongs_to :search_request

  before_validation :normalize_codes

  validates :position, presence: true, inclusion: { in: 1..4 }
  validates :origin_airport_code, :destination_airport_code, presence: true
  validate :position_is_contiguous

  private

  def normalize_codes
    self.origin_airport_code = origin_airport_code&.upcase
    self.destination_airport_code = destination_airport_code&.upcase
  end

  def position_is_contiguous
    return unless search_request

    sibling_positions = search_request.itinerary_legs.reject { |leg| leg.equal?(self) }.map(&:position)
    positions = (sibling_positions + [ position ]).compact.sort
    return if positions.empty?

    expected = (1..positions.length).to_a
    errors.add(:position, "航段順序必須連續") unless positions == expected
  end
end
