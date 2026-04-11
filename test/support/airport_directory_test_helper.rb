module AirportDirectoryTestHelper
  def create_airport(attributes = {})
    Airport.create!({
      source_identifier: "test:#{SecureRandom.hex(4)}",
      iata_code: "TPE",
      icao_code: "RCTP",
      official_name_en: "Taiwan Taoyuan International Airport",
      localized_name_zh: "台灣桃園國際機場",
      city_name: "桃園",
      country_name: "台灣",
      country_code: "TW",
      last_synced_at: Time.current,
      active: true
    }.merge(attributes))
  end

  def sync_seed_airports
    Airport.delete_all
    AirportDirectorySyncRun.delete_all
    AirportDirectory::SyncService.new.call
  end
end
