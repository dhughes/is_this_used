# frozen_string_literal: true

require "fileutils"
require "bundler"
Bundler::GemHelper.install_tasks

desc "Create the database."
task :create_db do
  system "mysqladmin -h #{ENV.fetch('IS_THIS_USED_DB_HOST', 'localhost')} -P #{ENV.fetch('IS_THIS_USED_DB_PORT', 3306)} -u #{ENV.fetch('IS_THIS_USED_DB_USER', 'root')} --password=#{ENV.fetch('IS_THIS_USED_DB_PASSWORD', 'dev')} drop is_this_used_test"
  system "mysqladmin -h #{ENV.fetch('IS_THIS_USED_DB_HOST', 'localhost')} -P #{ENV.fetch('IS_THIS_USED_DB_PORT', 3306)} -u #{ENV.fetch('IS_THIS_USED_DB_USER', 'root')} --password=#{ENV.fetch('IS_THIS_USED_DB_PASSWORD', 'dev')} create is_this_used_test"
end

desc "Default: run all available test suites"
task default: :spec
