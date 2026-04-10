class CreateExchangeRateSnapshots < ActiveRecord::Migration[8.1]
  def change
    create_table :exchange_rate_snapshots, id: false do |t|
      t.string :id, null: false, primary_key: true
      t.string :search_request_id, null: false
      t.string :base_currency, null: false
      t.json :rates_payload, null: false
      t.string :provider_key, null: false
      t.datetime :captured_at, null: false
      t.timestamps
    end

    add_index :exchange_rate_snapshots, :search_request_id, unique: true
    add_foreign_key :exchange_rate_snapshots, :search_requests, column: :search_request_id, primary_key: :id
  end
end
