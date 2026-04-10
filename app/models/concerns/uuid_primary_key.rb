module UuidPrimaryKey
  extend ActiveSupport::Concern

  included do
    before_validation :assign_uuid, on: :create
  end

  private

  def assign_uuid
    self.id ||= SecureRandom.uuid
  end
end
