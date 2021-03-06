# frozen_string_literal: true

Dummy::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # The test environment is used exclusively to run your application's
  # test suite. You never need to work with it otherwise. Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs. Don't rely on the data there!
  config.cache_classes = true

  # In Rails 6.0, rails/rails@3b95478 made a change to eagerly define attribute
  # methods of a Model when `eager_load` is enabled. If we used `eager_load`,
  # this would break our test suite because of the way we run migration. For
  # example, `People.attribute_names` would return an empty array.
  config.eager_load = false

  if config.respond_to?(:public_file_server)
    config.public_file_server.enabled = true
  elsif config.respond_to?(:serve_static_files=)
    config.serve_static_files = true
  else
    config.serve_static_assets = true
  end

  if config.respond_to?(:public_file_server)
    config.public_file_server.headers = {
      'Cache-Control' => 'public, max-age=3600'
    }
  else
    config.static_cache_control = 'public, max-age=3600'
  end

  # Show full error reports and disable caching
  config.consider_all_requests_local = true
  config.action_controller.perform_caching = false

  # Raise exceptions instead of rendering exception templates
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment
  config.action_controller.allow_forgery_protection = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  # config.action_mailer.delivery_method = :test

  # Print deprecation notices to the stderr
  config.active_support.deprecation = :stderr
end
