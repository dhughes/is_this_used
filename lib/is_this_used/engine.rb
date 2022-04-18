# frozen_string_literal: true

module IsThisUsed
  class Engine < ::Rails::Engine
    # TODO: I might actually want to add `isolate_namespace`, but that would require generating the tables with different names
    # isolate_namespace IsThisUsed
  end
end
