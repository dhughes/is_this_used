# frozen_string_literal: true

require "fileutils"
require "bundler"
require './spec/support/is_this_used_spec_migrator'
Bundler::GemHelper.install_tasks

desc "Create the database."
task :create_db do
  ENV['RAILS_ENV'] = 'test'
  system "mysqladmin -f -h #{ENV.fetch('IS_THIS_USED_DB_HOST', 'localhost')} -P #{ENV.fetch('IS_THIS_USED_DB_PORT', 3306)} -u #{ENV.fetch('IS_THIS_USED_DB_USER', 'root')} --password=#{ENV.fetch('IS_THIS_USED_DB_PASSWORD', 'dev')} drop is_this_used_test"
  system "mysqladmin -h #{ENV.fetch('IS_THIS_USED_DB_HOST', 'localhost')} -P #{ENV.fetch('IS_THIS_USED_DB_PORT', 3306)} -u #{ENV.fetch('IS_THIS_USED_DB_USER', 'root')} --password=#{ENV.fetch('IS_THIS_USED_DB_PASSWORD', 'dev')} create is_this_used_test"

  Bundler.setup
  require 'active_record/railtie'
  require 'is_this_used'
  require 'rspec/rails'

  require File.expand_path('spec/dummy_app/config/environment', __dir__)
  ::IsThisUsedSpecMigrator.new.migrate
end

desc "Default: run all available test suites"
task default: :spec
