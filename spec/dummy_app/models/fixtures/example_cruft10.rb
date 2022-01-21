# frozen_string_literal: true

require 'is_this_used/cruft_tracker'

module Fixtures
  class ExampleCruft10
    include IsThisUsed::CruftTracker

    def do_something_privately
      be_sneaky
    end

    private

    def be_sneaky
      'tip toe though the tulips'
    end

    is_this_used? :be_sneaky
  end
end
