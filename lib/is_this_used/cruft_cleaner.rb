# frozen_string_literal: true

module IsThisUsed
  class CruftCleaner
    def self.clean🧹
      IsThisUsed::PotentialCruft.where(deleted_at: nil).each do |potential_cruft|
        unless potential_cruft.still_exists? && potential_cruft.still_tracked?
          potential_cruft.update(deleted_at: Time.current)
        end
      end
    rescue StandardError
      # I'm actively ignoring all errors. Chances are, these are due to something like running rake
      # tasks in CI when the DB doesn't already exist.
    end
  end
end
