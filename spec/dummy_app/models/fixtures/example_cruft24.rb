# frozen_string_literal: true

require 'is_this_used/cruft_tracker'

module Fixtures
  class ExampleCruft24
    include IsThisUsed::CruftTracker

    def self.do_a_thing
      # consider it done
    end

    def self.be_sneaky
      # you can't see me!!
    end
    private_class_method :be_sneaky

    def do_something
      # Pretend I do something with these args
    end

    def do_something_argumentatively(thing_to_argue_about)
      # consider it done
    end
    is_this_used? :do_something_argumentatively, track_arguments: ->(args) { args.count }

    def do_something_protectidly
      # shh!
    end
    protected :do_something_protectidly

    private

    def do_something_privately
      # shh!
    end

    is_any_of_this_stuff_used?
  end
end
