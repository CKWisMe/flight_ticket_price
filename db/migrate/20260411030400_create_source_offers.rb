class CreateSourceOffers < ActiveRecord::Migration[8.1]
  def change
    create_table :source_offers, id: false do |t|
      t.string :id, null: false, primary_key: true
      t.string :search_request_id, null: false
      t.string :source_key, null: false
      t.string :source_offer_reference, null: false
      t.string :original_currency, null: false
      t.string :display_currency, null: false
      t.decimal :base_fare_amount, precision: 12, scale: 2, null: false, default: 0
      t.decimal :taxes_and_fees_amount, precision: 12, scale: 2, null: false, default: 0
      t.decimal :total_amount, precision: 12, scale: 2, null: false
      t.decimal :normalized_total_amount, precision: 12, scale: 2, null: false
      t.boolean :direct_flight, null: false, default: false
      t.integer :total_travel_minutes, null: false
      t.datetime :outbound_departure_at, null: false
      t.datetime :outbound_arrival_at, null: false
      t.datetime :return_departure_at
      t.datetime :return_arrival_at
      t.json :itinerary_payload, null: false
      t.string :booking_url, null: false
      t.datetime :fetched_at, null: false
      t.datetime :stale_at
      t.string :price_disclosure, null: false, default: ""
      t.string :seat_availability_disclosure, null: false, default: ""
      t.string :exchange_rate_disclosure, null: false, default: ""
      t.timestamps
    end

    add_index :source_offers, [ :search_request_id, :source_key, :source_offer_reference ], unique: true, name: "index_source_offers_on_request_and_source_reference"
    add_index :source_offers, [ :search_request_id, :normalized_total_amount ]
    add_foreign_key :source_offers, :search_requests, column: :search_request_id, primary_key: :id
  end
end
