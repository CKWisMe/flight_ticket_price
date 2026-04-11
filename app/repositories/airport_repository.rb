class AirportRepository
  MATCH_FIELDS = {
    iata_code: :normalized_iata_code,
    icao_code: :normalized_icao_code,
    official_name_en: :normalized_official_name_en,
    localized_name_zh: :normalized_localized_name_zh,
    city_name: :normalized_city_name
  }.freeze

  def search_active(query:, limit: 10)
    term = query.to_s
    return [] if term.blank?

    scope = Airport.active_only
    conditions = MATCH_FIELDS.values.filter_map do |column|
      next if column == :normalized_localized_name_zh

      "#{column} LIKE :prefix"
    end
    conditions << "normalized_localized_name_zh LIKE :prefix"

    scope
      .where(conditions.join(" OR "), prefix: "#{term}%")
      .limit(limit)
      .to_a
  end

  def active_code_exists?(code)
    normalized_code = Airports::NormalizeQueryService.normalize_code(code)
    return false if normalized_code.blank?

    Airport.active_only.where(
      "normalized_iata_code = :code OR normalized_icao_code = :code",
      code: normalized_code
    ).exists?
  end

  def upsert_from_source!(record:, synced_at:)
    attributes = build_attributes_from_source(record: record, synced_at: synced_at)
    airport = Airport.find_or_initialize_by(source_identifier: attributes[:source_identifier])
    airport.assign_attributes(attributes.except(:id, :created_at, :updated_at))
    airport.save!
    airport
  end

  def bulk_upsert_from_source!(records:, synced_at:)
    now = Time.current
    existing_rows = Airport.where(source_identifier: records.map { |record| record.fetch("sourceIdentifier") }).pluck(:source_identifier, :id, :created_at)
    existing_by_source_identifier = existing_rows.each_with_object({}) do |(source_identifier, id, created_at), result|
      result[source_identifier] = { id: id, created_at: created_at }
    end

    upsert_rows = records.map do |record|
      existing = existing_by_source_identifier[record.fetch("sourceIdentifier")]
      build_attributes_from_source(record: record, synced_at: synced_at).merge(
        id: existing&.fetch(:id, nil) || SecureRandom.uuid,
        created_at: existing&.fetch(:created_at, nil) || now,
        updated_at: now
      )
    end

    Airport.upsert_all(upsert_rows, unique_by: :index_airports_on_source_identifier)
    upsert_rows.size
  end

  def deactivate_missing!(source_identifiers:, synced_at:)
    scope = Airport.active_only.where.not(source_identifier: source_identifiers)
    count = scope.count
    scope.update_all(active: false, deactivated_at: synced_at, updated_at: Time.current)
    count
  end

  private

  def build_attributes_from_source(record:, synced_at:)
    iata_code = record["iataCode"]
    icao_code = record["icaoCode"]
    official_name_en = record.fetch("officialNameEn")
    localized_name_zh = record["localizedNameZh"]
    city_name = record.fetch("cityName")

    {
      source_identifier: record.fetch("sourceIdentifier"),
      iata_code: iata_code,
      icao_code: icao_code,
      official_name_en: official_name_en,
      localized_name_zh: localized_name_zh,
      city_name: city_name,
      country_name: record.fetch("countryName"),
      country_code: record["countryCode"],
      normalized_iata_code: Airports::NormalizeQueryService.normalize_code(iata_code),
      normalized_icao_code: Airports::NormalizeQueryService.normalize_code(icao_code),
      normalized_official_name_en: Airports::NormalizeQueryService.normalize_text(official_name_en),
      normalized_localized_name_zh: Airports::NormalizeQueryService.normalize_text(localized_name_zh),
      normalized_city_name: Airports::NormalizeQueryService.normalize_text(city_name),
      active: true,
      deactivated_at: nil,
      last_synced_at: synced_at
    }
  end
end
