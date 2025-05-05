require "active_record"
require "yaml"

env = ENV.fetch("RACK_ENV", :development).to_sym
db_config = YAML.load_file(File.expand_path("database.yml", __dir__))
ActiveRecord::Base.configurations = db_config
ActiveRecord::Base.establish_connection(env)

unless ActiveRecord::Base.connection.table_exists?("flipside_features")
  migration_path = File.expand_path("../lib/generators/flipside/install/templates", __dir__)
  migration_context = ActiveRecord::MigrationContext.new(migration_path)
  migration_context.migrate
end
