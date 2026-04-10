json.searchRequestId @search_request.id
json.status @status_payload[:status]
json.sourceStatuses @status_payload[:source_statuses] do |source_status|
  json.sourceKey source_status[:source_key]
  json.status source_status[:status]
  json.errorCode source_status[:error_code]
  json.fetchedAt source_status[:fetched_at]
end
