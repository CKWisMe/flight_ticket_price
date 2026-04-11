require "test_helper"

class AirportDirectory::SyncServiceTest < ActiveSupport::TestCase
  StubAdapter = Struct.new(:payload) do
    def fetch_snapshot
      payload
    end
  end

  StubRegistry = Struct.new(:payload, :enabled) do
    def enabled?
      enabled
    end

    def build
      StubAdapter.new(payload)
    end
  end

  test "syncs airports successfully" do
    payload = {
      "sourceKey" => "primary",
      "snapshotVersion" => "v1",
      "completeSnapshot" => true,
      "records" => [
        {
          "sourceIdentifier" => "stub:TPE",
          "iataCode" => "TPE",
          "icaoCode" => "RCTP",
          "officialNameEn" => "Taiwan Taoyuan International Airport",
          "localizedNameZh" => "台灣桃園國際機場",
          "cityName" => "桃園",
          "countryName" => "台灣",
          "countryCode" => "TW"
        }
      ]
    }

    result = AirportDirectory::SyncService.new(registry: StubRegistry.new(payload, true)).call

    assert result.errors.blank?
    assert_equal "succeeded", result.run.reload.status
    assert_equal 1, Airport.count
  end

  test "marks run as partially succeeded when one record fails" do
    payload = {
      "sourceKey" => "primary",
      "snapshotVersion" => "v1",
      "completeSnapshot" => true,
      "records" => [
        { "sourceIdentifier" => "good", "officialNameEn" => "Good Airport", "cityName" => "東京", "countryName" => "日本" },
        { "sourceIdentifier" => "bad", "cityName" => "東京", "countryName" => "日本" }
      ]
    }

    result = AirportDirectory::SyncService.new(registry: StubRegistry.new(payload, true)).call

    assert_equal "partially_succeeded", result.run.reload.status
    assert_equal 1, result.run.failed_record_count
  end

  test "deactivates missing airports on complete snapshot" do
    create_airport(source_identifier: "old")
    payload = {
      "sourceKey" => "primary",
      "snapshotVersion" => "v1",
      "completeSnapshot" => true,
      "records" => [
        { "sourceIdentifier" => "new", "iataCode" => "TPE", "icaoCode" => "RCTP", "officialNameEn" => "Taiwan Taoyuan International Airport", "localizedNameZh" => "台灣桃園國際機場", "cityName" => "桃園", "countryName" => "台灣", "countryCode" => "TW" }
      ]
    }

    AirportDirectory::SyncService.new(registry: StubRegistry.new(payload, true)).call

    assert_not Airport.find_by!(source_identifier: "old").active?
  end
end
