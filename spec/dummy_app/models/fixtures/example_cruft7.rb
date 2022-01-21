# frozen_string_literal: true

require 'is_this_used/cruft_tracker'

module Fixtures
  class ExampleCruft7
    include IsThisUsed::CruftTracker

    attr_accessor :name

    def initialize(name)
      @name = name
    end

    def self.hello
      'Hi'
    end

    def hello
      "Hi, #{name}"
    end

    is_this_used? :hello, method_type: IsThisUsed::CruftTracker::INSTANCE_METHOD
  end
end
