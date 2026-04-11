class AirportDirectorySyncRunRepository
  def start!(source_key:, source_snapshot_version: nil, started_at: Time.current)
    AirportDirectorySyncRun.create!(
      source_key: source_key,
      status: "failed",
      started_at: started_at,
      source_snapshot_version: source_snapshot_version,
      fetched_record_count: 0,
      upserted_record_count: 0,
      deactivated_record_count: 0,
      failed_record_count: 0
    )
  end

  def finish!(run:, status:, completed_at: Time.current, fetched_record_count:, upserted_record_count:, deactivated_record_count:, failed_record_count:, error_summary: nil, source_snapshot_version: run.source_snapshot_version)
    run.update!(
      status: status,
      completed_at: completed_at,
      fetched_record_count: fetched_record_count,
      upserted_record_count: upserted_record_count,
      deactivated_record_count: deactivated_record_count,
      failed_record_count: failed_record_count,
      error_summary: error_summary,
      source_snapshot_version: source_snapshot_version
    )
    run
  end

  def latest
    AirportDirectorySyncRun.order(started_at: :desc, created_at: :desc).first
  end
end
