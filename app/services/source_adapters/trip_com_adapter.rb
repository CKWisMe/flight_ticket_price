module SourceAdapters
  class TripComAdapter < BaseAdapter
    def fetch
      [
        {
          source_offer_reference: "trip-com-#{search_request.id}",
          original_currency: "TWD",
          base_fare_amount: 9800.0,
          taxes_and_fees_amount: 1700.0,
          total_amount: 11500.0,
          direct_flight: !search_request.direct_only,
          total_travel_minutes: search_request.direct_only ? 210 : 235,
          outbound_departure_at: outbound_departure_at(offset_minutes: 90),
          outbound_arrival_at: outbound_arrival_at(offset_minutes: 90, duration_minutes: search_request.direct_only ? 210 : 235),
          return_departure_at: return_departure_at(offset_minutes: 70),
          return_arrival_at: return_arrival_at(offset_minutes: 70, duration_minutes: 200),
          itinerary_payload: itinerary_payload,
          booking_url: "https://www.trip.com/flights/#{search_request.id}",
          fetched_at: Time.current,
          stale_at: 25.minutes.from_now,
          price_disclosure: "票價與稅費可能因來源更新而變動",
          seat_availability_disclosure: "座位保留與否以實際導流頁為準",
          exchange_rate_disclosure: "原始幣別與顯示幣別可能因匯率時間差異不同"
        }
      ]
    end
  end
end
