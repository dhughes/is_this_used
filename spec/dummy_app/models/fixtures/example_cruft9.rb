# frozen_string_literal: true

require 'dummy_app/models/fixtures/base_cruft'

module Fixtures
  class ExampleCruft9 < BaseCruft
    include IsThisUsed::CruftTracker

    attr_accessor :name

    def initialize(name)
      super()
      @name = name
    end

    def hello
      "Hi, #{name}"
    end

    is_this_used? :hello
  end
end
