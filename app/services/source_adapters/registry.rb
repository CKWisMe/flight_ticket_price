module SourceAdapters
  class Registry
    def initialize(config: load_config)
      @config = config.fetch("sources", {})
    end

    def enabled_source_keys
      config.select { |_key, settings| settings["enabled"] }.keys
    end

    def build(source_key, search_request:)
      case source_key.to_s
      when "skyscanner"
        SourceAdapters::SkyscannerAdapter.new(search_request:)
      when "trip_com"
        SourceAdapters::TripComAdapter.new(search_request:)
      else
        raise ArgumentError, "Unknown source: #{source_key}"
      end
    end

    def settings_for(source_key)
      config.fetch(source_key.to_s)
    end

    private

    attr_reader :config

    def load_config
      path = Rails.root.join("config/ticket_sources.yml")
      YAML.load_file(path, aliases: true).fetch(Rails.env)
    end
  end
end
