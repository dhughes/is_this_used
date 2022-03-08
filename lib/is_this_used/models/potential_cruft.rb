# frozen_string_literal: true

module IsThisUsed
  class PotentialCruft < ActiveRecord::Base
    has_many :potential_cruft_stacks,
             dependent: :destroy, class_name: 'IsThisUsed::PotentialCruftStack'
    has_many :potential_cruft_arguments,
             dependent: :destroy, class_name: 'IsThisUsed::PotentialCruftArgument'

    def still_exists?
      class_still_exists? && method_still_exists?
    end

    def still_tracked?
      IsThisUsed::Registry.instance.include?(self)
    end

    def ==(other)
      other.owner_name == owner_name &&
        other.method_name == method_name &&
        other.method_type == method_type
    end

    private

    def class_still_exists?
      Object.const_defined?(owner_name)
    end

    def clazz
      owner_name.constantize
    end

    def method_still_exists?
      case method_type
      when IsThisUsed::CruftTracker::INSTANCE_METHOD
        (clazz.instance_methods + clazz.private_instance_methods)
      when IsThisUsed::CruftTracker::CLASS_METHOD
        (clazz.methods + clazz.private_methods)
      end.
        include?(method_name.to_sym)
    end
  end
end
