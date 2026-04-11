module AirportDirectorySources
  class BaseAdapter
    def initialize(settings:)
      @settings = settings
    end

    def fetch_snapshot
      raise NotImplementedError, "#{self.class.name} must implement fetch_snapshot"
    end

    private

    attr_reader :settings
  end
end
