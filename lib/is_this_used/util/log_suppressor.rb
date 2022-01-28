# frozen_string_literal: true

module IsThisUsed
  module Util
    class LogSuppressor
      def self.suppress_logging
        initial_log_level = ActiveRecord::Base.logger.level
        ActiveRecord::Base.logger.level = :error
        yield
        ActiveRecord::Base.logger.level = initial_log_level
      end
    end
  end
end
