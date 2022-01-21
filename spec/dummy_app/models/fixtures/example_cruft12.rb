# frozen_string_literal: true

require 'is_this_used/cruft_tracker'

module Fixtures
  class ExampleCruft12
    include IsThisUsed::CruftTracker

    def self.do_the_sneaky_thing
      be_sneaky
    end

    def self.be_sneaky
      "you can't see me"
    end

    private_class_method :be_sneaky

    is_this_used? :be_sneaky
  end
end
