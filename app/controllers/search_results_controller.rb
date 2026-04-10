class SearchResultsController < ApplicationController
  def show
    @search_request = SearchRequestRepository.new.find!(params[:search_request_id])
    @sort = params[:sort].presence || "price"
    service = SearchRequests::StatusService.new(search_request: @search_request)
    @results_payload = service.results_payload(sort: @sort)
    @offers = SourceOfferRepository.new.for_search_request(@search_request, sort: @sort)

    respond_to do |format|
      format.html
      format.json
    end
  end
end
