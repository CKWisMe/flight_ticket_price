class AirportsController < ApplicationController
  def lookup
    result = Airports::LookupService.new(query: params[:query].to_s).call
    @lookup_result = result

    render :lookup
  end
end
