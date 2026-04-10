module SourceAdapters
  class SkyscannerAdapter < BaseAdapter
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
          booking_url: "https://www.skyscanner.com/transport/flights/#{search_request.id}",
          fetched_at: Time.current,
          stale_at: 30.minutes.from_now,
          price_disclosure: "價格可能隨售票來源更新而變動",
          seat_availability_disclosure: "座位供應狀態以售票來源頁面為準",
          exchange_rate_disclosure: "顯示幣別以本次搜尋匯率快照換算"
        }
      ]
    end
  end
end
