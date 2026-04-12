require "application_system_test_case"

class SearchResultComparisonTest < ApplicationSystemTestCase
  setup do
    create_airport(iata_code: "TPE", icao_code: "RCTP")
    create_airport(source_identifier: "nrt", iata_code: "NRT", icao_code: "RJAA", official_name_en: "Narita International Airport", localized_name_zh: "成田國際機場", city_name: "東京", country_name: "日本", country_code: "JP")
  end

  test "user can compare results and open booking links" do
    search_request = create_search_request_with_results

    visit search_request_results_path(search_request)

    assert_text "航班比較"
    assert_text "開啟訂票頁"
    assert_text "開啟供應商訂票頁前，先比較價格、時程與揭露資訊。"
    assert_link "回到首頁"
  end

  test "results page keeps back to home entry visible when no offers are available" do
    search_request = create_search_request_without_results

    visit search_request_results_path(search_request)

    assert_text "目前還沒有可顯示的票價，請稍後再查看搜尋來源的更新結果。"
    assert_link "回到首頁"
  end

  private

  def create_search_request_with_results
    perform_enqueued_jobs do
      SearchRequests::CreateService.call(params: {
        trip_type: "round_trip",
        origin_airport_code: "TPE",
        destination_airport_code: "NRT",
        direct_only: false,
        departure_window_start_on: Date.current + 7.days,
        departure_window_end_on: Date.current + 14.days,
        stay_length_days: 4,
        display_currency: "TWD",
        itinerary_legs: []
      })
    end
    SearchRequest.last
  end

  def create_search_request_without_results
    registry_double = Struct.new(:enabled_source_keys) do
      def settings_for(_source_key)
        { "timeout_seconds" => 15 }
      end

      def build(_source_key, search_request:)
        Class.new do
          def initialize(search_request:)
            @search_request = search_request
          end

          def fetch
            []
          end
        end.new(search_request:)
      end
    end.new(%w[skyscanner trip_com])

    registry_singleton = SourceAdapters::Registry.singleton_class
    original_new = SourceAdapters::Registry.method(:new)
    registry_singleton.send(:define_method, :new) { |*| registry_double }

    begin
      perform_enqueued_jobs do
        SearchRequests::CreateService.call(params: {
          trip_type: "round_trip",
          origin_airport_code: "TPE",
          destination_airport_code: "NRT",
          direct_only: false,
          departure_window_start_on: Date.current + 7.days,
          departure_window_end_on: Date.current + 14.days,
          stay_length_days: 4,
          display_currency: "TWD",
          itinerary_legs: []
        })
      end
    ensure
      registry_singleton.send(:define_method, :new) { |*args, **kwargs, &block| original_new.call(*args, **kwargs, &block) }
    end

    SearchRequest.last
  end
end
