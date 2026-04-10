class SourceFetchJob < ApplicationJob
  queue_as :default

  def perform(search_request_id, source_key)
    search_request_repository = SearchRequestRepository.new
    source_offer_repository = SourceOfferRepository.new
    registry = SourceAdapters::Registry.new

    search_request = search_request_repository.find!(search_request_id)
    search_request_repository.upsert_source_status!(
      search_request:,
      source_key:,
      status: "fetching"
    )

    adapter = registry.build(source_key, search_request:)
    timeout_seconds = registry.settings_for(source_key).fetch("timeout_seconds", 15)
    offers = Timeout.timeout(timeout_seconds) { adapter.fetch }
    rates_payload = search_request.exchange_rate_snapshot.rates_payload

    offers.each do |offer|
      normalized_total_amount = CurrencyConversion::NormalizeService.call(
        amount: offer.fetch(:total_amount),
        from_currency: offer.fetch(:original_currency),
        to_currency: search_request.display_currency,
        rates_payload:
      )

      source_offer_repository.upsert_offer!(
        search_request:,
        source_key:,
        offer_attributes: offer.merge(
          display_currency: search_request.display_currency,
          normalized_total_amount:
        )
      )
    end

    search_request_repository.upsert_source_status!(
      search_request:,
      source_key:,
      status: offers.any? ? "succeeded" : "no_results",
      fetched_at: Time.current
    )

    SearchRequests::RecommendationService.new(search_request:).call
    search_request_repository.refresh_aggregate_status!(search_request)
  rescue Timeout::Error
    search_request_repository.upsert_source_status!(
      search_request:,
      source_key:,
      status: "timed_out",
      error_code: "timeout",
      error_message: "來源回應逾時，請稍後再試",
      fetched_at: Time.current
    )
    search_request_repository.refresh_aggregate_status!(search_request)
  rescue StandardError => error
    search_request_repository.upsert_source_status!(
      search_request:,
      source_key:,
      status: "failed",
      error_code: error.class.name,
      error_message: "來源暫時無法取得資料",
      fetched_at: Time.current
    )
    search_request_repository.refresh_aggregate_status!(search_request)
  end
end
