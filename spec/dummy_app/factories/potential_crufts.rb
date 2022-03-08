# frozen_string_literal: true

FactoryBot.define do
  factory :potential_cruft, class: IsThisUsed::PotentialCruft do
    owner_name { "SomeClass" }
    method_name { "some_method" }
    method_type { IsThisUsed::CruftTracker::INSTANCE_METHOD }
  end
end
