require "test_helper"

class AirportDirectoryScheduleConfigurationTest < ActiveSupport::TestCase
  test "deploy configuration documents weekly airport sync schedule" do
    deploy_config = File.read(Rails.root.join("config/deploy.yml"))

    assert_includes deploy_config, "AIRPORT_DIRECTORY_SYNC_SCHEDULE"
    assert_includes deploy_config, "AirportDirectorySyncJob.perform_now"
  end
end
