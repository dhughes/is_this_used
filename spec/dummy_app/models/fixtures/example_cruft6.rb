# frozen_string_literal: true

require 'dummy_app/models/fixtures/example_module_cruft1'

module Fixtures
  class ExampleCruft6
    include ExampleModuleCruft1
  end
end
