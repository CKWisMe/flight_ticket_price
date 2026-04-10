module SourceAdapters
  class BaseAdapter
    def initialize(search_request:)
      @search_request = search_request
    end

    private

    attr_reader :search_request

    def itinerary_payload
      if search_request.multi_city?
        search_request.itinerary_legs.map do |leg|
          {
            originAirportCode: leg.origin_airport_code,
            destinationAirportCode: leg.destination_airport_code,
            departureOn: leg.departure_on&.iso8601
          }
        end
      else
        [
          {
            originAirportCode: search_request.origin_airport_code,
            destinationAirportCode: search_request.destination_airport_code,
            departureOn: search_request.departure_window_start_on.iso8601
          }
        ]
      end
    end

    def outbound_departure_at(offset_minutes: 0)
      search_request.departure_window_start_on.to_time.in_time_zone + 8.hours + offset_minutes.minutes
    end

    def outbound_arrival_at(offset_minutes: 0, duration_minutes: 180)
      outbound_departure_at(offset_minutes:) + duration_minutes.minutes
    end

    def return_departure_at(offset_minutes: 0)
      return nil if search_request.one_way? || search_request.multi_city?

      (search_request.departure_window_start_on + search_request.stay_length_days.days).to_time.in_time_zone + 15.hours + offset_minutes.minutes
    end

    def return_arrival_at(offset_minutes: 0, duration_minutes: 185)
      return nil unless return_departure_at(offset_minutes:)

      return_departure_at(offset_minutes:) + duration_minutes.minutes
    end
  end
end
