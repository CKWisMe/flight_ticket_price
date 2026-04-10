class CreateSearchRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :search_requests, id: false do |t|
      t.string :id, null: false, primary_key: true
      t.string :trip_type, null: false
      t.string :origin_airport_code
      t.string :destination_airport_code
      t.boolean :direct_only, null: false, default: false
      t.date :departure_window_start_on, null: false
      t.date :departure_window_end_on, null: false
      t.integer :stay_length_days, null: false
      t.string :display_currency, null: false
      t.string :status, null: false, default: "queued"
      t.datetime :requested_at, null: false
      t.datetime :completed_at
      t.timestamps
    end

    add_index :search_requests, :status
    add_index :search_requests, :requested_at
  end
end
