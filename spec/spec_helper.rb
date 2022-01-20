# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
ENV['DB'] ||= 'mysql'

# require 'bundler/setup'
# require 'is_this_used'
require 'pry-byebug'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path =
    '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

Bundler.setup
require 'active_record/railtie'
require 'is_this_used'
require 'rspec/rails'
require File.expand_path('dummy_app/config/environment', __dir__)

# Now that AR has a connection pool, we can migrate the database.
require_relative 'support/is_this_used_spec_migrator'
::IsThisUsedSpecMigrator.new.migrate

RSpec.configure do |config|
  config.fixture_path = nil # we use factories, not fixtures
  config.use_transactional_fixtures = true
end
