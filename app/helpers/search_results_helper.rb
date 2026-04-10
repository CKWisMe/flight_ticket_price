module SearchResultsHelper
  def search_result_sort_options
    [
      [ "價格", "price" ],
      [ "去程出發時間", "outbound_departure" ],
      [ "回程出發時間", "return_departure" ],
      [ "總旅行時間", "total_travel_time" ]
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
    return "目前尚無足夠結果可以產生推薦。" unless recommendation

    "推薦理由：#{recommendation.explanation}"
  end
end
