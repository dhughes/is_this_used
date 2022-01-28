# frozen_string_literal: true

module Fixtures
  class ExampleCruft13
    include IsThisUsed::CruftTracker

    def hello
      'Hi!'
    end

    is_this_used? :hello
  end
end
