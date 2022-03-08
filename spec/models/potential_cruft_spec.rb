# frozen_string_literal: true

require 'spec_helper'
require 'is_this_used/models/potential_cruft'
require 'is_this_used/models/potential_cruft_stack'
require 'dummy_app/models/fixtures/example_cruft19'

RSpec.describe IsThisUsed::PotentialCruft do
  it 'can be persisted' do
    potential_cruft =
      IsThisUsed::PotentialCruft.new(
        owner_name: 'Thingy',
        method_name: 'do_it',
        method_type: IsThisUsed::CruftTracker::INSTANCE_METHOD
      )

    expect { potential_cruft.save }.to change {
      IsThisUsed::PotentialCruft.count
    }.by(1)
  end

  it 'can have associated cruft stacks' do
    potential_cruft =
      IsThisUsed::PotentialCruft.create(
        owner_name: 'Thingy',
        method_name: 'do_it',
        method_type: IsThisUsed::CruftTracker::INSTANCE_METHOD,
        invocations: 123
      )
    IsThisUsed::PotentialCruftStack.create(
      potential_cruft: potential_cruft,
      stack_hash: 'ABC123',
      stack: [{ a: 123 }],
      occurrences: 123
    )

    expect(potential_cruft.potential_cruft_stacks.count).to eq(1)
  end

  describe '#still_exists?' do
    context 'when the class for a tracked method no longer exists' do
      it 'is false' do
        potential_cruft = IsThisUsed::PotentialCruft.create(
          owner_name: 'Thingy',
          method_name: 'do_it',
          method_type: IsThisUsed::CruftTracker::INSTANCE_METHOD,
          invocations: 123
        )

        expect(potential_cruft.still_exists?).to eq(false)
      end
    end

    context 'when a tracked instance method no longer exists' do
      it 'is false' do
        potential_cruft = IsThisUsed::PotentialCruft.create(
          owner_name: 'Fixtures::ExampleCruft19',
          method_name: 'some_nonexistent_method',
          method_type: IsThisUsed::CruftTracker::INSTANCE_METHOD,
          invocations: 123
        )

        expect(potential_cruft.still_exists?).to eq(false)
      end
    end

    context 'when a tracked class method no longer exists' do
      it 'is false' do
        potential_cruft = IsThisUsed::PotentialCruft.create(
          owner_name: 'Fixtures::ExampleCruft19',
          method_name: 'some_nonexistent_class_method',
          method_type: IsThisUsed::CruftTracker::CLASS_METHOD,
          invocations: 123
        )

        expect(potential_cruft.still_exists?).to eq(false)
      end
    end

    context 'when a tracked instance method exists' do
      it 'is true' do
        potential_cruft = IsThisUsed::PotentialCruft.create(
          owner_name: 'Fixtures::ExampleCruft19',
          method_name: 'do_something',
          method_type: IsThisUsed::CruftTracker::INSTANCE_METHOD,
          invocations: 123
        )

        expect(potential_cruft.still_exists?).to eq(true)
      end
    end

    context 'when a tracked private instance exists' do
      it 'is true' do
        potential_cruft = IsThisUsed::PotentialCruft.create(
          owner_name: 'Fixtures::ExampleCruft19',
          method_name: 'do_something_privately',
          method_type: IsThisUsed::CruftTracker::INSTANCE_METHOD,
          invocations: 123
        )

        expect(potential_cruft.still_exists?).to eq(true)
      end
    end

    context 'when a tracked protected instance exists' do
      it 'is true' do
        potential_cruft = IsThisUsed::PotentialCruft.create(
          owner_name: 'Fixtures::ExampleCruft19',
          method_name: 'do_something_protectidly',
          method_type: IsThisUsed::CruftTracker::INSTANCE_METHOD,
          invocations: 123
        )

        expect(potential_cruft.still_exists?).to eq(true)
      end
    end

    context 'when a tracked class method exists' do
      it 'is true' do
        potential_cruft = IsThisUsed::PotentialCruft.create(
          owner_name: 'Fixtures::ExampleCruft19',
          method_name: 'do_a_thing',
          method_type: IsThisUsed::CruftTracker::CLASS_METHOD,
          invocations: 123
        )

        expect(potential_cruft.still_exists?).to eq(true)
      end
    end

    context 'when a tracked private class method exists' do
      it 'is true' do
        potential_cruft = IsThisUsed::PotentialCruft.create(
          owner_name: 'Fixtures::ExampleCruft19',
          method_name: 'be_sneaky',
          method_type: IsThisUsed::CruftTracker::CLASS_METHOD,
          invocations: 123
        )

        expect(potential_cruft.still_exists?).to eq(true)
      end
    end
  end
end
