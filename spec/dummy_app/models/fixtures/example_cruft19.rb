# frozen_string_literal: true

require 'is_this_used/cruft_tracker'

module Fixtures
  class ExampleCruft19
    include IsThisUsed::CruftTracker

    def self.do_a_thing
      # consider it done
    end

    def self.be_sneaky
      # you can't see me!!
    end
    private_class_method :be_sneaky
    is_this_used? :be_sneaky

    def do_something
      # Pretend I do something with these args
    end

    is_this_used? :do_something

    def do_something_protectidly
      # shh!
    end
    protected :do_something_protectidly
    is_this_used? :do_something_protectidly

    private

    def do_something_privately
      # shh!
    end

    is_this_used? :do_something_privately
  end
end
