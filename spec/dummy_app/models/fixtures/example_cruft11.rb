# frozen_string_literal: true

require 'is_this_used/cruft_tracker'

module Fixtures
  class ExampleCruft11
    include IsThisUsed::CruftTracker

    def do_something_protected
      be_strong
    end

    protected

    def be_strong
      'wargarble'
    end

    is_this_used? :be_strong
  end
end
