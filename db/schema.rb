# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_04_11_030700) do
  create_table "airport_directory_sync_runs", id: :string, force: :cascade do |t|
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.integer "deactivated_record_count", default: 0, null: false
    t.text "error_summary"
    t.integer "failed_record_count", default: 0, null: false
    t.integer "fetched_record_count", default: 0, null: false
    t.string "source_key", null: false
    t.string "source_snapshot_version"
    t.datetime "started_at", null: false
    t.string "status", null: false
    t.datetime "updated_at", null: false
    t.integer "upserted_record_count", default: 0, null: false
    t.index ["started_at"], name: "index_airport_directory_sync_runs_on_started_at"
    t.index ["status"], name: "index_airport_directory_sync_runs_on_status"
  end

  create_table "airports", id: :string, force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "city_name", null: false
    t.string "country_code"
    t.string "country_name", null: false
    t.datetime "created_at", null: false
    t.datetime "deactivated_at"
    t.string "iata_code"
    t.string "icao_code"
    t.datetime "last_synced_at", null: false
    t.string "localized_name_zh"
    t.string "normalized_city_name", null: false
    t.string "normalized_iata_code"
    t.string "normalized_icao_code"
    t.string "normalized_localized_name_zh"
    t.string "normalized_official_name_en", null: false
    t.string "official_name_en", null: false
    t.string "source_identifier", null: false
    t.datetime "updated_at", null: false
    t.index ["active", "normalized_city_name"], name: "index_airports_on_active_and_normalized_city_name"
    t.index ["active", "normalized_iata_code"], name: "index_airports_on_active_and_normalized_iata_code"
    t.index ["active", "normalized_icao_code"], name: "index_airports_on_active_and_normalized_icao_code"
    t.index ["active", "normalized_official_name_en"], name: "index_airports_on_active_and_normalized_official_name_en"
    t.index ["active"], name: "index_airports_on_active"
    t.index ["source_identifier"], name: "index_airports_on_source_identifier", unique: true
  end

  create_table "exchange_rate_snapshots", id: :string, force: :cascade do |t|
    t.string "base_currency", null: false
    t.datetime "captured_at", null: false
    t.datetime "created_at", null: false
    t.string "provider_key", null: false
    t.json "rates_payload", null: false
    t.string "search_request_id", null: false
    t.datetime "updated_at", null: false
    t.index ["search_request_id"], name: "index_exchange_rate_snapshots_on_search_request_id", unique: true
  end

  create_table "itinerary_legs", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "departure_on"
    t.string "destination_airport_code", null: false
    t.string "origin_airport_code", null: false
    t.integer "position", null: false
    t.string "search_request_id", null: false
    t.datetime "updated_at", null: false
    t.index ["search_request_id", "position"], name: "index_itinerary_legs_on_search_request_id_and_position", unique: true
  end

  create_table "recommendations", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "explanation", null: false
    t.datetime "ranked_at", null: false
    t.string "reason_code", null: false
    t.string "search_request_id", null: false
    t.string "source_offer_id", null: false
    t.datetime "updated_at", null: false
    t.index ["search_request_id"], name: "index_recommendations_on_search_request_id", unique: true
  end

  create_table "search_requests", id: :string, force: :cascade do |t|
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.date "departure_window_end_on", null: false
    t.date "departure_window_start_on", null: false
    t.string "destination_airport_code"
    t.boolean "direct_only", default: false, null: false
    t.string "display_currency", null: false
    t.string "origin_airport_code"
    t.datetime "requested_at", null: false
    t.string "status", default: "queued", null: false
    t.integer "stay_length_days", null: false
    t.string "trip_type", null: false
    t.datetime "updated_at", null: false
    t.index ["requested_at"], name: "index_search_requests_on_requested_at"
    t.index ["status"], name: "index_search_requests_on_status"
  end

  create_table "source_offers", id: :string, force: :cascade do |t|
    t.decimal "base_fare_amount", precision: 12, scale: 2, default: "0.0", null: false
    t.string "booking_url", null: false
    t.datetime "created_at", null: false
    t.boolean "direct_flight", default: false, null: false
    t.string "display_currency", null: false
    t.string "exchange_rate_disclosure", default: "", null: false
    t.datetime "fetched_at", null: false
    t.json "itinerary_payload", null: false
    t.decimal "normalized_total_amount", precision: 12, scale: 2, null: false
    t.string "original_currency", null: false
    t.datetime "outbound_arrival_at", null: false
    t.datetime "outbound_departure_at", null: false
    t.string "price_disclosure", default: "", null: false
    t.datetime "return_arrival_at"
    t.datetime "return_departure_at"
    t.string "search_request_id", null: false
    t.string "seat_availability_disclosure", default: "", null: false
    t.string "source_key", null: false
    t.string "source_offer_reference", null: false
    t.datetime "stale_at"
    t.decimal "taxes_and_fees_amount", precision: 12, scale: 2, default: "0.0", null: false
    t.decimal "total_amount", precision: 12, scale: 2, null: false
    t.integer "total_travel_minutes", null: false
    t.datetime "updated_at", null: false
    t.index ["search_request_id", "normalized_total_amount"], name: "idx_on_search_request_id_normalized_total_amount_417ef0fa34"
    t.index ["search_request_id", "source_key", "source_offer_reference"], name: "index_source_offers_on_request_and_source_reference", unique: true
  end

  create_table "source_statuses", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "error_code"
    t.string "error_message"
    t.datetime "fetched_at"
    t.string "search_request_id", null: false
    t.string "source_key", null: false
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.index ["search_request_id", "source_key"], name: "index_source_statuses_on_search_request_id_and_source_key", unique: true
  end

  add_foreign_key "exchange_rate_snapshots", "search_requests"
  add_foreign_key "itinerary_legs", "search_requests"
  add_foreign_key "recommendations", "search_requests"
  add_foreign_key "recommendations", "source_offers"
  add_foreign_key "source_offers", "search_requests"
  add_foreign_key "source_statuses", "search_requests"
end
