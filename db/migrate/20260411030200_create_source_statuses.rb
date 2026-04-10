class CreateSourceStatuses < ActiveRecord::Migration[8.1]
  def change
    create_table :source_statuses, id: false do |t|
      t.string :id, null: false, primary_key: true
      t.string :search_request_id, null: false
      t.string :source_key, null: false
      t.string :status, null: false, default: "pending"
      t.datetime :fetched_at
      t.string :error_code
      t.string :error_message
      t.timestamps
    end

    add_index :source_statuses, [ :search_request_id, :source_key ], unique: true
    add_foreign_key :source_statuses, :search_requests, column: :search_request_id, primary_key: :id
  end
end
