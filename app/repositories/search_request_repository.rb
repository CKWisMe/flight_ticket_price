class SearchRequestRepository
  def create!(attributes:, itinerary_legs:, source_keys:, rates_payload:, provider_key:)
    SearchRequest.transaction do
      search_request = SearchRequest.new(attributes)
      itinerary_legs.each { |leg| search_request.itinerary_legs.build(leg) }
      search_request.save!

      source_keys.each do |source_key|
        search_request.source_statuses.create!(source_key: source_key, status: "pending")
      end

      search_request.create_exchange_rate_snapshot!(
        base_currency: search_request.display_currency,
        rates_payload: rates_payload,
        provider_key: provider_key,
        captured_at: Time.current
      )

      search_request
    end
  end

  def find!(id)
    SearchRequest.includes(:itinerary_legs, :source_statuses, :exchange_rate_snapshot, :recommendation).find(id)
  end

  def find(id)
    SearchRequest.includes(:itinerary_legs, :source_statuses, :exchange_rate_snapshot, :recommendation).find_by(id: id)
  end

  def update_status!(search_request, status:, completed_at: nil)
    search_request.update!(status: status, completed_at: completed_at)
  end

  def upsert_source_status!(search_request:, source_key:, status:, error_code: nil, error_message: nil, fetched_at: nil)
    record = search_request.source_statuses.find_or_initialize_by(source_key: source_key)
    record.status = status
    record.error_code = error_code
    record.error_message = error_message
    record.fetched_at = fetched_at
    record.save!
    record
  end

  def refresh_aggregate_status!(search_request)
    statuses = search_request.source_statuses.reload.map(&:status)
    success_present = statuses.any? { |status| %w[succeeded no_results].include?(status) }
    pending_present = statuses.any? { |status| %w[pending fetching].include?(status) }

    next_status =
      if pending_present && success_present
        "partially_completed"
      elsif pending_present
        "running"
      elsif statuses.any? { |status| status == "succeeded" }
        "completed"
      elsif success_present
        "completed"
      else
        "failed"
      end

    update_status!(search_request, status: next_status, completed_at: pending_present ? nil : Time.current)
  end
end
