module AirportDirectory
  class SyncService
    Result = Struct.new(:run, :errors, keyword_init: true) do
      def success?
        errors.blank?
      end
    end

    def initialize(registry: AirportDirectorySources::Registry.new, airport_repository: AirportRepository.new, sync_run_repository: AirportDirectorySyncRunRepository.new, clock: -> { Time.current })
      @registry = registry
      @airport_repository = airport_repository
      @sync_run_repository = sync_run_repository
      @clock = clock
    end

    def call
      raise "同步來源未啟用" unless registry.enabled?

      snapshot = registry.build.fetch_snapshot
      synced_at = clock.call
      run = sync_run_repository.start!(
        source_key: snapshot.fetch("sourceKey"),
        source_snapshot_version: snapshot["snapshotVersion"],
        started_at: synced_at
      )

      upserted_count = 0
      failed_count = 0
      errors = []
      source_identifiers = []

      Array(snapshot["records"]).each do |record|
        source_identifiers << record["sourceIdentifier"]
        airport_repository.upsert_from_source!(record: record, synced_at: synced_at)
        upserted_count += 1
      rescue StandardError => error
        failed_count += 1
        errors << "#{record['sourceIdentifier']}: #{error.message}"
      end

      deactivated_count =
        if ActiveModel::Type::Boolean.new.cast(snapshot["completeSnapshot"])
          airport_repository.deactivate_missing!(source_identifiers: source_identifiers, synced_at: synced_at)
        else
          0
        end

      status = if failed_count.zero?
        "succeeded"
      elsif upserted_count.positive?
        "partially_succeeded"
      else
        "failed"
      end

      sync_run_repository.finish!(
        run: run,
        status: status,
        completed_at: clock.call,
        fetched_record_count: Array(snapshot["records"]).size,
        upserted_record_count: upserted_count,
        deactivated_record_count: deactivated_count,
        failed_record_count: failed_count,
        error_summary: errors.first,
        source_snapshot_version: snapshot["snapshotVersion"]
      )

      Result.new(run: run, errors: errors)
    rescue StandardError => error
      Result.new(run: nil, errors: [ error.message ])
    end

    private

    attr_reader :registry, :airport_repository, :sync_run_repository, :clock
  end
end
