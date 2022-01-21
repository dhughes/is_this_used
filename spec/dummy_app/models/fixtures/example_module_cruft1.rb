# frozen_string_literal: true

require 'is_this_used/cruft_tracker'

module Fixtures
  module ExampleModuleCruft1
    include IsThisUsed::CruftTracker

    def i_like_turtles
      true
    end

    is_this_used? :i_like_turtles
  end
end
