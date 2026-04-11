class CreateAirports < ActiveRecord::Migration[8.1]
  def change
    create_table :airports, id: :string do |t|
      t.string :source_identifier, null: false
      t.string :iata_code
      t.string :icao_code
      t.string :official_name_en, null: false
      t.string :localized_name_zh
      t.string :city_name, null: false
      t.string :country_name, null: false
      t.string :country_code
      t.string :normalized_iata_code
      t.string :normalized_icao_code
      t.string :normalized_official_name_en, null: false
      t.string :normalized_localized_name_zh
      t.string :normalized_city_name, null: false
      t.boolean :active, null: false, default: true
      t.datetime :deactivated_at
      t.datetime :last_synced_at, null: false
      t.timestamps
    end

    add_index :airports, :source_identifier, unique: true
    add_index :airports, :active
    add_index :airports, [ :active, :normalized_city_name ]
    add_index :airports, [ :active, :normalized_iata_code ]
    add_index :airports, [ :active, :normalized_icao_code ]
    add_index :airports, [ :active, :normalized_official_name_en ]
  end
end
