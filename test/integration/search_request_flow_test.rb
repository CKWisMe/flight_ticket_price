require "test_helper"

class SearchRequestFlowTest < ActionDispatch::IntegrationTest
  setup do
    create_airport(iata_code: "TPE", icao_code: "RCTP")
    create_airport(source_identifier: "test:nrt", iata_code: "NRT", icao_code: "RJAA", official_name_en: "Narita International Airport", localized_name_zh: "成田國際機場", city_name: "東京", country_name: "日本", country_code: "JP")
  end

  test "single source failure does not prevent other results from showing" do
    registry_double = Struct.new(:enabled_source_keys) do
      def settings_for(_source_key)
        { "timeout_seconds" => 15 }
      end

      def build(source_key, search_request:)
        if source_key == "trip_com"
          raise StandardError, "boom"
        else
          SourceAdapters::SkyscannerAdapter.new(search_request:)
        end
      end
    end.new(%w[skyscanner trip_com])

    registry_singleton = SourceAdapters::Registry.singleton_class
    original_new = SourceAdapters::Registry.method(:new)
    registry_singleton.send(:define_method, :new) { |*| registry_double }

    begin
      perform_enqueued_jobs do
        post search_requests_path, params: {
          tripType: "round_trip",
          originAirportCode: "TPE",
          destinationAirportCode: "NRT",
          directOnly: false,
          departureWindowStartOn: (Date.current + 7.days).iso8601,
          departureWindowEndOn: (Date.current + 14.days).iso8601,
          stayLengthDays: 4,
          displayCurrency: "TWD",
          itineraryLegs: []
        }, as: :json
      end
    ensure
      registry_singleton.send(:define_method, :new) { |*args, **kwargs, &block| original_new.call(*args, **kwargs, &block) }
    end

    search_request = SearchRequest.last
    assert_equal "failed", search_request.source_statuses.find_by(source_key: "trip_com").status
    assert_equal "succeeded", search_request.source_statuses.find_by(source_key: "skyscanner").status
    assert_operator search_request.source_offers.count, :>=, 1
  end

  test "no results keeps source statuses visible without offers" do
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
        post search_requests_path, params: {
          tripType: "round_trip",
          originAirportCode: "TPE",
          destinationAirportCode: "NRT",
          directOnly: false,
          departureWindowStartOn: (Date.current + 7.days).iso8601,
          departureWindowEndOn: (Date.current + 14.days).iso8601,
          stayLengthDays: 4,
          displayCurrency: "TWD",
          itineraryLegs: []
        }, as: :json
      end
    ensure
      registry_singleton.send(:define_method, :new) { |*args, **kwargs, &block| original_new.call(*args, **kwargs, &block) }
    end

    search_request = SearchRequest.last
    assert_equal 0, search_request.source_offers.count
    assert_equal %w[no_results no_results], search_request.source_statuses.order(:source_key).pluck(:status)
  end
end
