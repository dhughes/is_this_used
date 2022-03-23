# frozen_string_literal: true

require 'is_this_used/cruft_tracker'

module Fixtures
  class ExampleCruft22
    include IsThisUsed::CruftTracker

    def do_something
      # consider it done
    end
    is_this_used? :do_something
  end
end
