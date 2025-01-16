# frozen_string_literal: true

require "bundler/setup"
require "active_record"
require "yaml"
require "logger"
require "byebug"
require "flipside"

# Load and establish connection to the database
ActiveRecord::Base.configurations = YAML.load_file(File.expand_path("database.yml", __dir__))
ActiveRecord::Base.establish_connection(:test)

# Optional: Enable logging if you want to see SQL queries during tests
# ActiveRecord::Base.logger = Logger.new(STDOUT)

migration_path = File.expand_path("../lib/generators/flipside/install/templates", __dir__)
migration_context = ActiveRecord::MigrationContext.new(migration_path)
migration_context.migrate

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.after do
    Flipside::Feature.destroy_all
    Flipside::Entity.destroy_all
    Flipside::Role.destroy_all
    Flipside::Value.destroy_all
  end
end
