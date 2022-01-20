# frozen_string_literal: true

module IsThisUsed
  class PotentialCruftStack < ActiveRecord::Base
    belongs_to :potential_cruft, class_name: 'IsThisUsed::PotentialCruft'
  end
end
