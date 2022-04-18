# frozen_string_literal: true

require 'spec_helper'
require 'is_this_used/util/log_suppressor'

RSpec.describe IsThisUsed::Util::LogSuppressor do
  it 'sets log level back to original log level' do
    original_log_level = ActiveRecord::Base.logger.level

    expect do
      IsThisUsed::Util::LogSuppressor.suppress_logging { raise 'error' }
    end.to raise_error('error')
    expect(ActiveRecord::Base.logger.level).to eq(original_log_level)
  end
end
