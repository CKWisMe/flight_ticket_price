class SourceStatus < ApplicationRecord
  include UuidPrimaryKey

  enum :status, {
    pending: "pending",
    fetching: "fetching",
    succeeded: "succeeded",
    no_results: "no_results",
    timed_out: "timed_out",
    failed: "failed",
    disabled: "disabled"
  }, validate: true

  belongs_to :search_request

  validates :source_key, presence: true
  validates :error_message, length: { maximum: 255 }, allow_blank: true
end
