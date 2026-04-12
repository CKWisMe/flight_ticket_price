module ApplicationHelper
  def trip_type_options
    [
      [ t("search_requests.form.trip_types.one_way"), "one_way" ],
      [ t("search_requests.form.trip_types.round_trip"), "round_trip" ],
      [ t("search_requests.form.trip_types.multi_city"), "multi_city" ]
    ]
  end
end
