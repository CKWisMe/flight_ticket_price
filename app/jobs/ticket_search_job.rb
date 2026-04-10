class TicketSearchJob < ApplicationJob
  queue_as :default

  def perform(search_request_id)
    repository = SearchRequestRepository.new
    search_request = repository.find!(search_request_id)
    registry = SourceAdapters::Registry.new

    repository.update_status!(search_request, status: "running")

    registry.enabled_source_keys.each do |source_key|
      SourceFetchJob.perform_later(search_request.id, source_key)
    end
  end
end
