# frozen_string_literal: true

require 'spec_helper'
require 'is_this_used/cruft_tracker'
require 'is_this_used/models/potential_cruft'
require 'dummy_app/models/fixtures/example_cruft19'
require 'dummy_app/models/fixtures/example_cruft20'

RSpec.describe IsThisUsed::CruftTracker do
  it 'cleans up potential cruft records for methods and classes that no longer exist' do
    cruft_records_that_should_not_be_deleted = [
      IsThisUsed::PotentialCruft.create(
        owner_name: 'Fixtures::ExampleCruft19',
        method_name: 'do_something',
        method_type: IsThisUsed::CruftTracker::INSTANCE_METHOD
      ),
      IsThisUsed::PotentialCruft.create(
        owner_name: 'Fixtures::ExampleCruft19',
        method_name: 'do_something_privately',
        method_type: IsThisUsed::CruftTracker::INSTANCE_METHOD
      ),
      IsThisUsed::PotentialCruft.create(
        owner_name: 'Fixtures::ExampleCruft19',
        method_name: 'do_something_protectidly',
        method_type: IsThisUsed::CruftTracker::INSTANCE_METHOD
      ),
      IsThisUsed::PotentialCruft.create(
        owner_name: 'Fixtures::ExampleCruft19',
        method_name: 'do_a_thing',
        method_type: IsThisUsed::CruftTracker::CLASS_METHOD
      ),
      IsThisUsed::PotentialCruft.create(
        owner_name: 'Fixtures::ExampleCruft19',
        method_name: 'be_sneaky',
        method_type: IsThisUsed::CruftTracker::CLASS_METHOD
      )
    ]
    cruft_records_that_should_be_deleted = [
      IsThisUsed::PotentialCruft.create(
        owner_name: 'Thingy',
        method_name: 'do_it',
        method_type: IsThisUsed::CruftTracker::INSTANCE_METHOD
      ),
      IsThisUsed::PotentialCruft.create(
        owner_name: 'Fixtures::ExampleCruft19',
        method_name: 'some_nonexistent_method',
        method_type: IsThisUsed::CruftTracker::INSTANCE_METHOD
      ),
      IsThisUsed::PotentialCruft.create(
        owner_name: 'Fixtures::ExampleCruft19',
        method_name: 'some_nonexistent_class_method',
        method_type: IsThisUsed::CruftTracker::CLASS_METHOD
      ),
      IsThisUsed::PotentialCruft.create(
        owner_name: 'Fixtures::ExampleCruft20',
        method_name: 'do_something',
        method_type: IsThisUsed::CruftTracker::INSTANCE_METHOD
      )
    ]

    IsThisUsed::CruftCleaner.clean🧹

    expect(IsThisUsed::PotentialCruft.all.size).to eq(9)
    expect(IsThisUsed::PotentialCruft.where(deleted_at: nil)).
      to match_array(cruft_records_that_should_not_be_deleted)
    expect(IsThisUsed::PotentialCruft.where.not(deleted_at: nil)).
      to match_array(cruft_records_that_should_be_deleted)
  end

end
