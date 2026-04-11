module SearchRequests
  class CreateService
    Result = Struct.new(:search_request, :errors, keyword_init: true) do
      def success?
        errors.blank?
      end
    end

    def self.call(params:)
      new(params:).call
    end

    def initialize(params:, search_request_repository: SearchRequestRepository.new, exchange_rate_repository: ExchangeRateRepository.new, airport_repository: AirportRepository.new)
      @params = params.to_h.deep_symbolize_keys
      @search_request_repository = search_request_repository
      @exchange_rate_repository = exchange_rate_repository
      @airport_repository = airport_repository
    end

    def call
      normalized_attributes = request_attributes
      itinerary_legs = normalized_itinerary_legs
      validation_errors = airport_validation_errors(normalized_attributes, itinerary_legs)

      if validation_errors.any?
        search_request = SearchRequest.new(normalized_attributes)
        validation_errors.each do |field, message|
          search_request.errors.add(field, message)
        end

        return Result.new(
          search_request: search_request,
          errors: search_request.errors.map { |entry| { field: entry.attribute, message: entry.message } }
        )
      end

      rates_payload, provider_key = exchange_rate_repository.fetch_rates(base_currency: normalized_attributes[:display_currency])
      source_keys = SourceAdapters::Registry.new.enabled_source_keys

      search_request = search_request_repository.create!(
        attributes: normalized_attributes,
        itinerary_legs: itinerary_legs,
        source_keys: source_keys,
        rates_payload: rates_payload,
        provider_key: provider_key
      )

      TicketSearchJob.perform_later(search_request.id)
      Result.new(search_request: search_request, errors: [])
    rescue ActiveRecord::RecordInvalid => error
      Result.new(
        search_request: error.record,
        errors: error.record.errors.map { |entry| { field: entry.attribute, message: entry.message } }
      )
    end

    private

    attr_reader :params, :search_request_repository, :exchange_rate_repository, :airport_repository

    def request_attributes
      {
        trip_type: params[:trip_type],
        origin_airport_code: params[:origin_airport_code],
        destination_airport_code: params[:destination_airport_code],
        direct_only: ActiveModel::Type::Boolean.new.cast(params[:direct_only]),
        departure_window_start_on: params[:departure_window_start_on],
        departure_window_end_on: params[:departure_window_end_on],
        stay_length_days: params[:stay_length_days],
        display_currency: params[:display_currency],
        status: "queued"
      }
    end

    def normalized_itinerary_legs
      Array(params[:itinerary_legs]).filter_map do |leg|
        leg = leg.to_h.deep_symbolize_keys
        next if leg[:origin_airport_code].blank? && leg[:destination_airport_code].blank?

        {
          position: leg[:position],
          origin_airport_code: leg[:origin_airport_code],
          destination_airport_code: leg[:destination_airport_code],
          departure_on: leg[:departure_on]
        }
      end
    end

    def airport_validation_errors(normalized_attributes, itinerary_legs)
      return [] if itinerary_legs.any?

      errors = []
      errors << [ :origin_airport_code, "must be selected from airport suggestions" ] unless airport_repository.active_code_exists?(normalized_attributes[:origin_airport_code])
      errors << [ :destination_airport_code, "must be selected from airport suggestions" ] unless airport_repository.active_code_exists?(normalized_attributes[:destination_airport_code])
      errors
    end
  end
end
