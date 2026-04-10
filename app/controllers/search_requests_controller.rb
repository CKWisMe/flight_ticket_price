class SearchRequestsController < ApplicationController
  def new
    @search_request = SearchRequest.new(
      trip_type: "round_trip",
      direct_only: false,
      departure_window_start_on: Date.current + 7.days,
      departure_window_end_on: Date.current + 14.days,
      stay_length_days: 5,
      display_currency: "TWD"
    )
  end

  def create
    result = SearchRequests::CreateService.call(params: normalized_params)

    respond_to do |format|
      if result.success?
        format.html { redirect_to search_request_path(result.search_request), notice: "搜尋已建立，正在彙整來源結果。" }
        format.json do
          @search_request = result.search_request
          render :create, status: :accepted
        end
      else
        format.html do
          @search_request = result.search_request || SearchRequest.new
          flash.now[:alert] = "請修正搜尋條件後再試一次"
          render :new, status: :unprocessable_entity
        end
        format.json { render json: { errors: result.errors }, status: :unprocessable_entity }
      end
    end
  end

  def show
    @search_request = SearchRequestRepository.new.find!(params[:id])
    @status_payload = SearchRequests::StatusService.new(search_request: @search_request).status_payload
  end

  private

  def normalized_params
    request_params = params[:search_request].presence || params

    {
      trip_type: request_params[:trip_type] || request_params[:tripType],
      origin_airport_code: request_params[:origin_airport_code] || request_params[:originAirportCode],
      destination_airport_code: request_params[:destination_airport_code] || request_params[:destinationAirportCode],
      direct_only: request_params.key?(:direct_only) ? request_params[:direct_only] : request_params[:directOnly],
      departure_window_start_on: request_params[:departure_window_start_on] || request_params[:departureWindowStartOn],
      departure_window_end_on: request_params[:departure_window_end_on] || request_params[:departureWindowEndOn],
      stay_length_days: request_params[:stay_length_days] || request_params[:stayLengthDays],
      display_currency: request_params[:display_currency] || request_params[:displayCurrency],
      itinerary_legs: normalize_itinerary_legs(request_params[:itinerary_legs] || request_params[:itineraryLegs])
    }
  end

  def normalize_itinerary_legs(raw_legs)
    Array(raw_legs).map do |leg|
      leg = leg.respond_to?(:to_unsafe_h) ? leg.to_unsafe_h : leg.to_h
      {
        position: leg["position"] || leg[:position],
        origin_airport_code: leg["origin_airport_code"] || leg[:origin_airport_code] || leg["originAirportCode"] || leg[:originAirportCode],
        destination_airport_code: leg["destination_airport_code"] || leg[:destination_airport_code] || leg["destinationAirportCode"] || leg[:destinationAirportCode],
        departure_on: leg["departure_on"] || leg[:departure_on] || leg["departureOn"] || leg[:departureOn]
      }
    end
  end
end
