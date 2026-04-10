class CreateRecommendations < ActiveRecord::Migration[8.1]
  def change
    create_table :recommendations, id: false do |t|
      t.string :id, null: false, primary_key: true
      t.string :search_request_id, null: false
      t.string :source_offer_id, null: false
      t.string :reason_code, null: false
      t.string :explanation, null: false
      t.datetime :ranked_at, null: false
      t.timestamps
    end

    add_index :recommendations, :search_request_id, unique: true
    add_foreign_key :recommendations, :search_requests, column: :search_request_id, primary_key: :id
    add_foreign_key :recommendations, :source_offers, column: :source_offer_id, primary_key: :id
  end
end
