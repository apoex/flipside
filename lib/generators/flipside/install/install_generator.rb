# require "rails/generators"
require "rails/generators/active_record"

module Flipside
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include ActiveRecord::Generators::Migration

      # Makes this generator available as "rails generate feature_flags:install"
      source_root File.expand_path("templates", __dir__)

      def create_migration_file
        # Check if the migration file already exists to avoid duplicates
        unless ActiveRecord::Base.connection.table_exists?("flipside")
          migration_template "20241122_create_flipside_migration.rb", "db/migrate/create_flipside_migration.rb"
        end
      end
    end
  end
end
