class AirportDirectorySyncRun < ApplicationRecord
  include UuidPrimaryKey

  enum :status, {
    succeeded: "succeeded",
    partially_succeeded: "partially_succeeded",
    failed: "failed"
  }, validate: true

  validates :source_key, :status, :started_at, presence: true
  validates :fetched_record_count, :upserted_record_count, :deactivated_record_count, :failed_record_count,
    numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate :completed_at_required_for_finished_status

  private

  def completed_at_required_for_finished_status
    return if failed?
    return if completed_at.present?

    errors.add(:completed_at, "不能空白")
  end
end
