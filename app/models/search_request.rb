class SearchRequest < ApplicationRecord
  include UuidPrimaryKey

  enum :trip_type, {
    one_way: "one_way",
    round_trip: "round_trip",
    multi_city: "multi_city"
  }, validate: true

  enum :status, {
    queued: "queued",
    running: "running",
    partially_completed: "partially_completed",
    completed: "completed",
    failed: "failed"
  }, validate: true

  has_many :itinerary_legs, -> { order(:position) }, dependent: :destroy
  has_many :source_offers, dependent: :destroy
  has_many :source_statuses, dependent: :destroy
  has_one :recommendation, dependent: :destroy
  has_one :exchange_rate_snapshot, dependent: :destroy

  accepts_nested_attributes_for :itinerary_legs

  before_validation :normalize_codes
  before_validation :set_requested_at, on: :create

  validates :display_currency, :departure_window_start_on, :departure_window_end_on, :stay_length_days, presence: true
  validates :direct_only, inclusion: { in: [ true, false ] }
  validates :stay_length_days, numericality: { only_integer: true, greater_than: 0 }
  validate :validate_trip_requirements
  validate :validate_departure_window

  def finished?
    completed? || failed?
  end

  private

  def normalize_codes
    self.origin_airport_code = origin_airport_code&.upcase
    self.destination_airport_code = destination_airport_code&.upcase
    self.display_currency = display_currency&.upcase
  end

  def set_requested_at
    self.requested_at ||= Time.current
  end

  def validate_trip_requirements
    if multi_city?
      if itinerary_legs.size < 2 || itinerary_legs.size > 4
        errors.add(:itinerary_legs, "多點進出需填寫 2 到 4 段航程")
      end
    else
      errors.add(:origin_airport_code, "不能空白") if origin_airport_code.blank?
      errors.add(:destination_airport_code, "不能空白") if destination_airport_code.blank?
      errors.add(:itinerary_legs, "單程或來回不需填寫多段航程") if itinerary_legs.any?
    end
  end

  def validate_departure_window
    return if departure_window_start_on.blank? || departure_window_end_on.blank?

    if departure_window_end_on < departure_window_start_on
      errors.add(:departure_window_end_on, "不得早於可出發區間起始日")
    end

    return unless stay_length_days.present?

    available_days = (departure_window_end_on - departure_window_start_on).to_i
    if round_trip? && available_days < stay_length_days
      errors.add(:departure_window_end_on, "日期區間不足以容納旅遊天數")
    end
  end
end
