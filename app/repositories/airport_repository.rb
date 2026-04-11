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
    airport = Airport.find_or_initialize_by(source_identifier: record.fetch("sourceIdentifier"))
    airport.assign_attributes(
      iata_code: record["iataCode"],
      icao_code: record["icaoCode"],
      official_name_en: record.fetch("officialNameEn"),
      localized_name_zh: record["localizedNameZh"],
      city_name: record.fetch("cityName"),
      country_name: record.fetch("countryName"),
      country_code: record["countryCode"],
      active: true,
      deactivated_at: nil,
      last_synced_at: synced_at
    )
    airport.save!
    airport
  end

  def deactivate_missing!(source_identifiers:, synced_at:)
    scope = Airport.active_only.where.not(source_identifier: source_identifiers)
    count = scope.count
    scope.update_all(active: false, deactivated_at: synced_at, updated_at: Time.current)
    count
  end
end
