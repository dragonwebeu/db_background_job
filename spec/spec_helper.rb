# frozen_string_literal: true

require "db_background_job"
require 'active_record'

ActiveRecord::Base.establish_connection(
    adapter: 'postgresql',
    database: 'test_database_name',
    username: 'test_user',
    password: 'test_password',
    host: 'localhost',
    port: 5432
)
RSpec.configure do |config|

  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
