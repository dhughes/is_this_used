# frozen_string_literal: true

module Fixtures
  class ExampleInvoker3
    def do_it
      ExampleCruft3.new('Bob').hello
    end
  end
end
