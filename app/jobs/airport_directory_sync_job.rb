class AirportDirectorySyncJob < ApplicationJob
  queue_as :default

  def perform
    AirportDirectory::SyncService.new.call
  end
end
