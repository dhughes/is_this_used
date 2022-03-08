# frozen_string_literal: true

module IsThisUsed
  class CruftCleaner
    def self.reset
      @already_cleaned = false
    end

    def self.clean✨
      @already_cleaned ||= false

      return if @already_cleaned

      IsThisUsed::PotentialCruft.all.each do |potential_cruft|
        if !Object.const_defined?(potential_cruft.owner_name) ||
          !potential_cruft.owner_name.constantize.methods.include?(potential_cruft.method_name.to_sym)
          binding.pry
          potential_cruft.update(deleted_at: Time.current)
        end
      end

      @already_cleaned = true
    end
  end
end
