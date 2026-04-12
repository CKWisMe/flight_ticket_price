module SearchResultsHelper
  def search_result_sort_options
    [
      [ t("search_results.sort_options.price"), "price" ],
      [ t("search_results.sort_options.outbound_departure"), "outbound_departure" ],
      [ t("search_results.sort_options.return_departure"), "return_departure" ],
      [ t("search_results.sort_options.total_travel_time"), "total_travel_time" ]
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

  def translated_search_request_status(status)
    t("search_requests.statuses.#{status}", default: status.to_s.humanize)
  end

  def translated_source_status(status)
    t("search_requests.source_statuses.#{status}", default: status.to_s.humanize)
  end

  def translated_trip_type(trip_type)
    t("search_requests.form.trip_types.#{trip_type}", default: trip_type.to_s.humanize)
  end

  def recommendation_message(recommendation)
    return t("search_results.recommendation.empty") unless recommendation

    t("search_results.recommendation.present", explanation: recommendation.explanation)
  end
end
