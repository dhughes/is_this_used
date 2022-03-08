# frozen_string_literal: true

require 'is_this_used/cruft_tracker'

module Fixtures
  class CruftToClean3
    include IsThisUsed::CruftTracker

    def wtf
      puts ">>>> wtf?"
    end

    private

    def existing_private_method
      puts ">>>> does this do anything?"
    end

    is_this_used? :existing_private_method
  end
end
