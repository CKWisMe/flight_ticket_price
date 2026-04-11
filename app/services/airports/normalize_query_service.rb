module Airports
  class NormalizeQueryService
    QueryParts = Struct.new(:normalized_query, :search_term, :country_hint, keyword_init: true)

    def self.call(query)
      normalized_query = normalize_text(query)
      tokens = normalized_query.split(" ")

      QueryParts.new(
        normalized_query: normalized_query,
        search_term: tokens.first.to_s,
        country_hint: tokens.drop(1).join(" ").presence
      )
    end

    def self.normalize_text(value)
      value.to_s.unicode_normalize(:nfkc).strip.downcase.gsub(/\s+/, " ")
    end

    def self.normalize_code(value)
      normalized = normalize_text(value)
      normalized.delete(" ")
    end
  end
end
