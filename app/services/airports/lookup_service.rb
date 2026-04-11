module Airports
  class LookupService
    Result = Struct.new(:query, :normalized_query, :matches, keyword_init: true)

    MATCH_PRIORITY = {
      iata_code: 0,
      icao_code: 1,
      localized_name_zh: 2,
      official_name_en: 3,
      city_name: 4
    }.freeze

    def initialize(query:, limit: 10, repository: AirportRepository.new)
      @query = query.to_s
      @limit = limit
      @repository = repository
    end

    def call
      query_parts = Airports::NormalizeQueryService.call(query)
      candidates = repository.search_active(query: query_parts.search_term, limit: limit * 3)

      Result.new(
        query: query,
        normalized_query: query_parts.normalized_query,
        matches: sort_candidates(candidates, query_parts).first(limit).map { |airport| serialize_match(airport, query_parts) }
      )
    end

    private

    attr_reader :query, :limit, :repository

    def sort_candidates(candidates, query_parts)
      candidates.sort_by do |airport|
        [
          country_match_rank(airport, query_parts),
          MATCH_PRIORITY.fetch(match_type_for(airport, query_parts.search_term)),
          airport.display_name
        ]
      end
    end

    def country_match_rank(airport, query_parts)
      return 1 if query_parts.country_hint.blank?

      hint = query_parts.country_hint
      country_name = Airports::NormalizeQueryService.normalize_text(airport.country_name)
      country_code = Airports::NormalizeQueryService.normalize_code(airport.country_code)
      (hint == country_name || hint == country_code) ? 0 : 1
    end

    def match_type_for(airport, search_term)
      return :iata_code if airport.normalized_iata_code&.start_with?(search_term)
      return :icao_code if airport.normalized_icao_code&.start_with?(search_term)
      return :localized_name_zh if airport.normalized_localized_name_zh&.start_with?(search_term)
      return :official_name_en if airport.normalized_official_name_en&.start_with?(search_term)

      :city_name
    end

    def serialize_match(airport, query_parts)
      {
        airport: airport,
        airport_code: airport.airport_code,
        match_type: match_type_for(airport, query_parts.search_term).to_s
      }
    end
  end
end
