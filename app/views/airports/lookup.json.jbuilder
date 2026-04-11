json.query @lookup_result.query
json.normalizedQuery @lookup_result.normalized_query
json.matches @lookup_result.matches do |match|
  airport = match.fetch(:airport)
  json.airportId airport.id
  json.displayName "#{airport.display_name} - #{airport.city_name}, #{airport.country_name}"
  json.airportCode match.fetch(:airport_code)
  json.icaoCode airport.icao_code
  json.cityName airport.city_name
  json.countryName airport.country_name
  json.countryCode airport.country_code
  json.matchType match.fetch(:match_type)
  json.selectable true
end
