# frozen_string_literal: true

require_relative "lib/flipside/version"

Gem::Specification.new do |spec|
  spec.name = "flipside"
  spec.version = Flipside::VERSION
  spec.authors = ["Sammy Henningsson"]
  spec.email = ["sammy.henningsson@apoex.se"]

  spec.summary = "Feature flags."
  spec.description = "Create simple feature toggles."
  # spec.homepage = "TODO: Put your gem's website or public repo URL here."
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  # spec.metadata["homepage_uri"] = spec.homepage
  # spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir['lib/**/*rb'] \
             + Dir['app/**/*rb'] \
             + %w[CHANGELOG.md LICENSE.txt README.md]

  spec.require_paths = ["app", "lib"]

  spec.add_dependency "activerecord", ">= 6.0"

  spec.add_development_dependency "byebug"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "sqlite3", ">= 2.1"
  spec.add_development_dependency "timecop"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
