# frozen_string_literal: true

module IsThisUsed
  class Registry
    include Singleton

    attr_accessor :potential_crufts

    def initialize
      @potential_crufts = []
    end

    def <<(potential_cruft)
      potential_crufts << potential_cruft
    end

    def include?(potential_cruft)
      potential_crufts.include?(potential_cruft)
    end
  end
end
