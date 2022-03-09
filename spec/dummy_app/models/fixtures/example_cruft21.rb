# frozen_string_literal: true

require 'is_this_used/cruft_tracker'

module Fixtures
  class ExampleCruft21
    include IsThisUsed::CruftTracker

    def do_a_thing
      # consider it done
    end
    is_this_used? :do_a_thing
  end
end
