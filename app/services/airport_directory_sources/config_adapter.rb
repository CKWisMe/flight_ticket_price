module AirportDirectorySources
  class ConfigAdapter < BaseAdapter
    def fetch_snapshot
      {
        "sourceKey" => settings.fetch("key"),
        "snapshotVersion" => settings["snapshot_version"],
        "completeSnapshot" => settings.fetch("complete_snapshot", true),
        "records" => Array(settings["records"]).map { |record| record.deep_stringify_keys }
      }
    end
  end
end
