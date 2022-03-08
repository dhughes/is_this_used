# frozen_string_literal: true

# Here a conventional app would load the Rails components it needs, but we have
# already loaded these in our spec_helper.
# require "active_record/railtie"
# require "action_controller/railtie"

# Here a conventional app would require gems, but again, we have already loaded
# these in our spec_helper.
# Bundler.require(:default, Rails.env)

require 'rails'

module Dummy
  class Application < ::Rails::Application
    config.load_defaults(::Rails.gem_version.segments.take(2).join('.'))

    config.encoding = 'utf-8'
    config.filter_parameters += %i[password]
    config.active_support.escape_html_entities_in_json = true
    config.active_support.test_order = :sorted
    config.secret_key_base =
      'A fox regularly kicked the screaming pile of biscuits.'

    config.encoding = 'utf-8'
  end
end
