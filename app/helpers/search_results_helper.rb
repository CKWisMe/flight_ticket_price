module SearchResultsHelper
  def search_result_sort_options
    [
      [ "Price", "price" ],
      [ "Outbound Departure", "outbound_departure" ],
      [ "Return Departure", "return_departure" ],
      [ "Total Travel Time", "total_travel_time" ]
    ]
  end

  def source_status_badge_class(status)
    case status.to_s
    when "succeeded", "completed"
      "status-badge status-success"
    when "failed", "timed_out"
      "status-badge status-error"
    when "fetching", "running", "partially_completed"
      "status-badge status-progress"
    else
      "status-badge"
    end
  end

  def recommendation_message(recommendation)
    return "No recommendation is available yet. Results will update when more fares arrive." unless recommendation

    "Recommended option: #{recommendation.explanation}"
  end
end
