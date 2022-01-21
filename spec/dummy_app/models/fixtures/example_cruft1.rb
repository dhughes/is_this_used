# frozen_string_literal: true

require 'is_this_used/cruft_tracker'

module Fixtures
  module ExampleCruft1
    include IsThisUsed::CruftTracker

    attr_accessor :name

    def initialize(name)
      @name = name
    end

    def self.jump_up_and_down
      'boing boing boing'
    end

    is_this_used? :jump_up_and_down

    def hello
      "Hi, #{name}"
    end

    is_this_used? :hello
  end
end
