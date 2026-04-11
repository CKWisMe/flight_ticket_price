class Airport < ApplicationRecord
  include UuidPrimaryKey

  before_validation :normalize_lookup_fields

  validates :source_identifier, presence: true, uniqueness: true
  validates :official_name_en, :city_name, :country_name, :normalized_official_name_en, :normalized_city_name, :last_synced_at, presence: true
  validates :active, inclusion: { in: [ true, false ] }
  validates :iata_code, format: { with: /\A[A-Z0-9]{3}\z/, message: "格式不正確" }, allow_blank: true
  validates :icao_code, format: { with: /\A[A-Z0-9]{4}\z/, message: "格式不正確" }, allow_blank: true

  scope :active_only, -> { where(active: true) }

  def airport_code
    iata_code.presence || icao_code.presence
  end

  def display_name
    code = airport_code || "N/A"
    name = localized_name_zh.presence || official_name_en
    "#{name} (#{code})"
  end

  private

  def normalize_lookup_fields
    self.iata_code = iata_code&.unicode_normalize(:nfkc)&.strip&.upcase
    self.icao_code = icao_code&.unicode_normalize(:nfkc)&.strip&.upcase
    self.country_code = country_code&.unicode_normalize(:nfkc)&.strip&.upcase
    self.normalized_iata_code = Airports::NormalizeQueryService.normalize_code(iata_code)
    self.normalized_icao_code = Airports::NormalizeQueryService.normalize_code(icao_code)
    self.normalized_official_name_en = Airports::NormalizeQueryService.normalize_text(official_name_en)
    self.normalized_localized_name_zh = Airports::NormalizeQueryService.normalize_text(localized_name_zh)
    self.normalized_city_name = Airports::NormalizeQueryService.normalize_text(city_name)
  end
end
