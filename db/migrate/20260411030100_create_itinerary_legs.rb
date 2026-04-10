class CreateItineraryLegs < ActiveRecord::Migration[8.1]
  def change
    create_table :itinerary_legs, id: false do |t|
      t.string :id, null: false, primary_key: true
      t.string :search_request_id, null: false
      t.integer :position, null: false
      t.string :origin_airport_code, null: false
      t.string :destination_airport_code, null: false
      t.date :departure_on
      t.timestamps
    end

    add_index :itinerary_legs, [ :search_request_id, :position ], unique: true
    add_foreign_key :itinerary_legs, :search_requests, column: :search_request_id, primary_key: :id
  end
end
