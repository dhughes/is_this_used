# frozen_string_literal: true

module IsThisUsed
  class Railtie < Rails::Railtie
    initializer "is_this_used_railtie.configure_rails_initialization" do
      # some initialization behavior
      puts ">>>> got here maybe?"

      config.after_initialize do
        puts ">>>> we've initialized?"
        puts ">>>> num of cruft: #{IsThisUsed::PotentialCruft.count}"
      end
    rescue StandardError
      # Swallow all errors to prevent initialization failures.
    end
  end
end
