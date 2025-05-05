# frozen_string_literal: true

$: << File.expand_path("..", __dir__)
ENV["RACK_ENV"] = "test"

require "config/database"
require "bundler/setup"
require "yaml"
require "logger"
require "byebug"
require "flipside"

# Optional: Enable logging if you want to see SQL queries during tests
# ActiveRecord::Base.logger = Logger.new(STDOUT)

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
  end
end
