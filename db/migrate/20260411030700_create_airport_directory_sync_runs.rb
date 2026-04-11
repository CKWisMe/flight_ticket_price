class CreateAirportDirectorySyncRuns < ActiveRecord::Migration[8.1]
  def change
    create_table :airport_directory_sync_runs, id: :string do |t|
      t.string :source_key, null: false
      t.string :status, null: false
      t.datetime :started_at, null: false
      t.datetime :completed_at
      t.string :source_snapshot_version
      t.integer :fetched_record_count, null: false, default: 0
      t.integer :upserted_record_count, null: false, default: 0
      t.integer :deactivated_record_count, null: false, default: 0
      t.integer :failed_record_count, null: false, default: 0
      t.text :error_summary
      t.timestamps
    end

    add_index :airport_directory_sync_runs, :started_at
    add_index :airport_directory_sync_runs, :status
  end
end
