require "csv"
require "net/http"
require "uri"

module AirportDirectorySources
  class OurAirportsAdapter < BaseAdapter
    DEFAULT_TIMEOUT_SECONDS = 30
    AIRPORT_NAME_PATTERN = /機場|机场|空港|航空站|飛行場|飞行场/

    def initialize(settings:, http_get: nil, clock: -> { Time.current.utc })
      super(settings:)
      @http_get = http_get || method(:default_http_get)
      @clock = clock
    end

    def fetch_snapshot
      country_names = load_country_names
      records = load_airport_records(country_names)

      {
        "sourceKey" => settings.fetch("key"),
        "snapshotVersion" => clock.call.iso8601,
        "completeSnapshot" => settings.fetch("complete_snapshot", true),
        "records" => records
      }
    end

    private

    attr_reader :http_get, :clock

    def load_country_names
      csv_rows(settings.fetch("countries_url")).each_with_object({}) do |row, result|
        code = row["code"].to_s.strip.upcase
        name = row["name"].to_s.strip
        next if code.blank? || name.blank?

        result[code] = {
          en: name,
          zh: best_localized_country_name(row)
        }
      end
    end

    def load_airport_records(country_names)
      csv_rows(settings.fetch("airports_url")).filter_map do |row|
        build_record(row, country_names)
      end
    end

    def csv_rows(url)
      CSV.parse(normalized_body(http_get.call(url)), headers: true)
    end

    def build_record(row, country_names)
      return if row["type"].to_s == "closed_airport"

      official_name_en = row["name"].to_s.strip
      return if official_name_en.blank?

      iata_code = normalized_iata_code(row["iata_code"])
      icao_code = normalized_icao_code(row["gps_code"]) || normalized_icao_code(row["ident"])
      return if iata_code.blank? && icao_code.blank?

      country_code = row["iso_country"].to_s.strip.upcase.presence
      localized_keywords = extract_localized_keywords(row["keywords"])
      localized_name_zh = best_localized_airport_name(localized_keywords)
      country_name = best_country_name(country_names, country_code)
      city_name = best_city_name(
        municipality: row["municipality"],
        official_name_en: official_name_en,
        localized_keywords: localized_keywords,
        localized_airport_name: localized_name_zh,
        country_name: country_name
      )

      {
        "sourceIdentifier" => "our_airports:#{row['id'] || row['ident']}",
        "iataCode" => iata_code,
        "icaoCode" => icao_code,
        "officialNameEn" => official_name_en,
        "localizedNameZh" => localized_name_zh,
        "cityName" => city_name,
        "countryName" => country_name,
        "countryCode" => country_code
      }
    end

    def best_localized_country_name(row)
      extract_localized_keywords(row["keywords"])
        .select { |keyword| keyword.length.between?(2, 12) }
        .min_by(&:length) || extract_localized_keywords(row["keywords"]).max_by(&:length)
    end

    def best_country_name(country_names, country_code)
      country = country_names[country_code]
      country&.fetch(:zh, nil).presence || country&.fetch(:en, nil).presence || country_code || "Unknown"
    end

    def best_city_name(municipality:, official_name_en:, localized_keywords:, localized_airport_name:, country_name:)
      municipality_name = municipality.to_s.strip
      return municipality_name if contains_han_characters?(municipality_name)

      localized_city_name = localized_keywords
        .reject { |keyword| keyword == localized_airport_name || keyword == country_name }
        .reject { |keyword| airport_name?(keyword) }
        .select { |keyword| keyword.length.between?(2, 12) }
        .min_by(&:length)

      localized_city_name.presence || municipality_name.presence || official_name_en
    end

    def best_localized_airport_name(localized_keywords)
      localized_keywords
        .select { |keyword| airport_name?(keyword) }
        .max_by(&:length) || localized_keywords.max_by(&:length)
    end

    def extract_localized_keywords(raw_keywords)
      raw_keywords.to_s.split(",").filter_map do |keyword|
        normalized_keyword = keyword.to_s.strip
        next if normalized_keyword.blank?
        next unless contains_han_characters?(normalized_keyword)

        normalized_keyword
      end.uniq
    end

    def airport_name?(value)
      value.to_s.match?(AIRPORT_NAME_PATTERN)
    end

    def contains_han_characters?(value)
      value.to_s.match?(/\p{Han}/)
    end

    def normalized_iata_code(value)
      code = value.to_s.strip.upcase
      code.match?(/\A[A-Z0-9]{3}\z/) ? code : nil
    end

    def normalized_icao_code(value)
      code = value.to_s.strip.upcase
      code.match?(/\A[A-Z0-9]{4}\z/) ? code : nil
    end

    def default_http_get(url)
      uri = URI.parse(url)
      response = Net::HTTP.start(
        uri.host,
        uri.port,
        use_ssl: uri.scheme == "https",
        open_timeout: timeout_seconds,
        read_timeout: timeout_seconds
      ) do |http|
        http.request(Net::HTTP::Get.new(uri))
      end

      raise "Airport directory download failed: #{uri} returned #{response.code}" unless response.is_a?(Net::HTTPSuccess)

      response.body
    end

    def normalized_body(body)
      body.to_s.dup.force_encoding(Encoding::UTF_8).encode(Encoding::UTF_8, invalid: :replace, undef: :replace, replace: "")
    end

    def timeout_seconds
      Integer(settings.fetch("timeout_seconds", DEFAULT_TIMEOUT_SECONDS))
    end
  end
end
