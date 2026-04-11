module SourceAdapters
  class SkyscannerAdapter < BaseAdapter
    SKYSCANNER_REFERRAL_BASE_URL = "https://skyscanner.net/g/referrals/v1".freeze

    def fetch
      [
        {
          source_offer_reference: "skyscanner-#{search_request.id}",
          original_currency: "USD",
          base_fare_amount: 320.0,
          taxes_and_fees_amount: 45.0,
          total_amount: 365.0,
          direct_flight: true,
          total_travel_minutes: 180,
          outbound_departure_at: outbound_departure_at,
          outbound_arrival_at: outbound_arrival_at(duration_minutes: 180),
          return_departure_at: return_departure_at,
          return_arrival_at: return_arrival_at(duration_minutes: 185),
          itinerary_payload: itinerary_payload,
          booking_url: booking_url,
          fetched_at: Time.current,
          stale_at: 30.minutes.from_now,
          price_disclosure: "Prices may change on the provider page before purchase.",
          seat_availability_disclosure: "Seat availability is confirmed by the provider during checkout.",
          exchange_rate_disclosure: "Displayed totals may vary if the provider settles in another currency."
        }
      ]
    end

    private

    def booking_url
      if search_request.multi_city?
        referral_url("flights/multicity", multicity_params)
      else
        referral_url("flights/day-view", day_view_params)
      end
    end

    def day_view_params
      params = {
        origin: search_request.origin_airport_code,
        destination: search_request.destination_airport_code,
        outboundDate: search_request.departure_window_start_on.iso8601,
        adultsv2: 1,
        cabinclass: "economy",
        preferDirects: search_request.direct_only,
        currency: search_request.display_currency
      }

      if search_request.round_trip?
        params[:inboundDate] = (search_request.departure_window_start_on + search_request.stay_length_days.days).iso8601
      end

      params.merge(localization_params)
    end

    def multicity_params
      params = {
        adultsv2: 1,
        cabinclass: "economy",
        currency: search_request.display_currency
      }

      search_request.itinerary_legs.each_with_index do |leg, index|
        params[:"origin#{index}"] = leg.origin_airport_code
        params[:"destination#{index}"] = leg.destination_airport_code
        params[:"date#{index}"] = leg.departure_on.iso8601 if leg.departure_on.present?
      end

      params.merge(localization_params)
    end

    def localization_params
      case search_request.display_currency
      when "TWD"
        { market: "TW", locale: "zh-TW" }
      when "JPY"
        { market: "JP", locale: "ja-JP" }
      else
        { market: "US", locale: "en-US" }
      end
    end

    def referral_url(page_type, params)
      "#{SKYSCANNER_REFERRAL_BASE_URL}/#{page_type}?#{params.compact.to_query}"
    end
  end
end
