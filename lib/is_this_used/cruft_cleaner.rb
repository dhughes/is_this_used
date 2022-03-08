# frozen_string_literal: true

module IsThisUsed
  class CruftCleaner
    def clean🧹
      IsThisUsed::PotentialCruft.all.each do |potential_cruft|
        unless potential_cruft.still_exists? && potential_cruft.still_tracked?
          potential_cruft.update(deleted_at: Time.current)
        end
      end
    end
  end
end
