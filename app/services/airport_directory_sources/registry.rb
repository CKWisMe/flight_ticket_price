module AirportDirectorySources
  class Registry
    def initialize(config: load_config)
      @source_config = config.fetch("source")
    end

    def source_key
      source_config.fetch("key")
    end

    def enabled?
      ActiveModel::Type::Boolean.new.cast(source_config.fetch("enabled", true))
    end

    def build
      case source_config.fetch("adapter")
      when "config"
        AirportDirectorySources::ConfigAdapter.new(settings: source_config)
      when "our_airports"
        AirportDirectorySources::OurAirportsAdapter.new(settings: source_config)
      else
        raise ArgumentError, "Unknown airport directory adapter: #{source_config['adapter']}"
      end
    end

    private

    attr_reader :source_config

    def load_config
      YAML.load_file(Rails.root.join("config/airport_directory_sources.yml"), aliases: true).fetch(Rails.env)
    end
  end
end
