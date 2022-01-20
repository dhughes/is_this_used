# frozen_string_literal: true

require 'spec_helper'
require 'models/potential_cruft'
require 'models/potential_cruft_stack'

RSpec.describe IsThisUsed::PotentialCruft do
  it 'can be persisted' do
    potential_cruft =
      IsThisUsed::PotentialCruft.new(
        owner_name: 'Thingy',
        method_name: 'do_it',
        method_type: 'instance_method'
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
        method_type: 'instance_method',
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
end
