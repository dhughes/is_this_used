# frozen_string_literal: true

module IsThisUsed
  class PotentialCruft < ActiveRecord::Base
    has_many :potential_cruft_stacks,
             dependent: :destroy, class_name: 'IsThisUsed::PotentialCruftStack'
  end
end
