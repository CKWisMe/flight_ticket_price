class Recommendation < ApplicationRecord
  include UuidPrimaryKey

  belongs_to :search_request
  belongs_to :source_offer

  validates :reason_code, :explanation, :ranked_at, presence: true
end
