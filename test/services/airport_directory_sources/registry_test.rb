require "test_helper"

class AirportDirectorySources::RegistryTest < ActiveSupport::TestCase
  test "builds an ourairports adapter when configured" do
    registry = AirportDirectorySources::Registry.new(
      config: {
        "source" => {
          "key" => "primary",
          "adapter" => "our_airports",
          "enabled" => true,
          "airports_url" => "https://example.test/airports.csv",
          "countries_url" => "https://example.test/countries.csv"
        }
      }
    )

    assert_instance_of AirportDirectorySources::OurAirportsAdapter, registry.build
    assert_predicate registry, :enabled?
    assert_equal "primary", registry.source_key
  end
end
