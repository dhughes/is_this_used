# frozen_string_literal: true

require 'is_this_used/cruft_tracker'

module Fixtures
  class ExampleCruft17
    include IsThisUsed::CruftTracker

    def do_something(number, string, boolean, array, array_of_hashes, hash)
      # Pretend I do something with these args
    end

    is_this_used? :do_something, track_arguments: -> (args) { args.last.keys.sort }

  end
end
