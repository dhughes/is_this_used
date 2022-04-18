require 'is_this_used/version'
require 'is_this_used/cruft_tracker'
require 'is_this_used/cruft_cleaner'
require 'is_this_used/registry'
require 'is_this_used/models/potential_cruft'
require 'is_this_used/models/potential_cruft_stack'
require 'is_this_used/models/potential_cruft_argument'
require 'is_this_used/util/log_suppressor'
require 'is_this_used/engine'

module IsThisUsed
  class Error < StandardError; end
end

require 'is_this_used/railtie' if defined?(Rails)

