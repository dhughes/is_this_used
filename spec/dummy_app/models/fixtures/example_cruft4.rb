# frozen_string_literal: true

require 'is_this_used/cruft_tracker'

module Fixtures
  class ExampleCruft4
    include IsThisUsed::CruftTracker

    is_this_used? :hello
  end
end
