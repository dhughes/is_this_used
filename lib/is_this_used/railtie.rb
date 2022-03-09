# frozen_string_literal: true

module IsThisUsed
  class Railtie < Rails::Railtie
    initializer "is_this_used_railtie.configure_post_initialize_cleanup" do

      config.after_initialize do
        if Rails.application.config.eager_load
          IsThisUsed::CruftCleaner.clean🧹
        end
      end

    rescue StandardError
      # Swallow all errors to prevent initialization failures.
    end
  end
end
