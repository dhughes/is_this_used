# frozen_string_literal: true

require 'spec_helper'
require 'is_this_used/cruft_tracker'
require 'is_this_used/models/potential_cruft'
require 'is_this_used/models/potential_cruft_stack'

RSpec.describe IsThisUsed::CruftTracker do
  it 'creates potential cruft records before methods are invoked' do
    require 'dummy_app/models/fixtures/example_cruft1'

    expect(IsThisUsed::PotentialCruft.count).to eq(2)
    jump_up_and_down_method =
      IsThisUsed::PotentialCruft.find_by(method_name: :jump_up_and_down)
    expect(jump_up_and_down_method.owner_name).to eq('Fixtures::ExampleCruft1')
    expect(jump_up_and_down_method.method_type).to eq(
      IsThisUsed::CruftTracker::CLASS_METHOD
    )
    expect(jump_up_and_down_method.invocations).to eq(0)
    hello_method = IsThisUsed::PotentialCruft.find_by(method_name: :hello)
    expect(hello_method.owner_name).to eq('Fixtures::ExampleCruft1')
    expect(hello_method.method_type).to eq(
      IsThisUsed::CruftTracker::INSTANCE_METHOD
    )
    expect(hello_method.invocations).to eq(0)
  end

  it 'tracks when a method is invoked' do
    require 'dummy_app/models/fixtures/example_cruft2'

    travel_to 5.minutes.from_now do
      zelda = Fixtures::ExampleCruft2.new('Zelda')
      zelda.hello
      zelda.hello

      expect(IsThisUsed::PotentialCruft.count).to eq(1)
      cruft = IsThisUsed::PotentialCruft.first
      expect(cruft.owner_name).to eq('Fixtures::ExampleCruft2')
      expect(cruft.method_type).to eq(IsThisUsed::CruftTracker::INSTANCE_METHOD)
      expect(cruft.invocations).to eq(2)
      expect(cruft.updated_at > cruft.created_at).to eq(true)
    end
  end

  it 'tracks unique filtered stack traces for method invocations' do
    require 'dummy_app/models/fixtures/example_cruft3'
    require 'dummy_app/models/fixtures/example_invoker3'

    travel_to 5.minutes.from_now do
      Fixtures::ExampleCruft3.new('Zelda').hello
      2.times { Fixtures::ExampleInvoker3.new.do_it }

      expect(IsThisUsed::PotentialCruft.count).to eq(1)
      cruft = IsThisUsed::PotentialCruft.first
      expect(cruft.owner_name).to eq('Fixtures::ExampleCruft3')
      expect(cruft.method_type).to eq(IsThisUsed::CruftTracker::INSTANCE_METHOD)
      expect(cruft.invocations).to eq(3)
      expect(cruft.updated_at > cruft.created_at).to eq(true)
      stacks = cruft.potential_cruft_stacks
      expect(stacks.size).to eq(2)
      expect(stacks.first.occurrences).to eq(1)
      expect(stacks.second.occurrences).to eq(2)
      expect(stacks.second.stack.first['base_label']).to eq('do_it')
    end
  end

  context 'when the method does not exist' do
    it 'raises' do
      expect do
        require 'dummy_app/models/fixtures/example_cruft4'
      end.to raise_error(IsThisUsed::NoSuchMethod)
    end
  end

  context 'when there are instance and class methods with the same name' do
    context 'when the type is not specified' do
      it 'raises' do
        expect do
          require 'dummy_app/models/fixtures/example_cruft5'
        end.to raise_error(IsThisUsed::AmbiguousMethodType)
      end
    end
  end

  context 'with a method in a module' do
    it 'tracks it' do
      require 'dummy_app/models/fixtures/example_cruft6'

      Fixtures::ExampleCruft6.new.i_like_turtles

      expect(IsThisUsed::PotentialCruft.count).to eq(1)
      cruft = IsThisUsed::PotentialCruft.first
      expect(cruft.owner_name).to eq('Fixtures::ExampleModuleCruft1')
      expect(cruft.invocations).to eq(1)
    end
  end

  context 'when the method_type is specified as instance' do
    it 'tracks for the instance method' do
      require 'dummy_app/models/fixtures/example_cruft7'

      Fixtures::ExampleCruft7.hello
      Fixtures::ExampleCruft7.new('Charlie').hello

      expect(IsThisUsed::PotentialCruft.count).to eq(1)
      cruft = IsThisUsed::PotentialCruft.first
      expect(cruft.invocations).to eq(1)
      expect(cruft.method_type).to eq(IsThisUsed::CruftTracker::INSTANCE_METHOD)
    end
  end

  context 'when the method_type is specified as class' do
    it 'tracks for the class method' do
      require 'dummy_app/models/fixtures/example_cruft8'

      Fixtures::ExampleCruft8.hello
      Fixtures::ExampleCruft8.new('Charlie').hello

      expect(IsThisUsed::PotentialCruft.count).to eq(1)
      cruft = IsThisUsed::PotentialCruft.first
      expect(cruft.invocations).to eq(1)
      expect(cruft.method_type).to eq(IsThisUsed::CruftTracker::CLASS_METHOD)
    end
  end

  it 'tracks the method itself, not overrides or super methods' do
    require 'dummy_app/models/fixtures/base_cruft'
    require 'dummy_app/models/fixtures/example_cruft9'
    require 'dummy_app/models/fixtures/specific_example_cruft9'
    require 'dummy_app/models/fixtures/enthusiastic_example_cruft9'

    expect(IsThisUsed::PotentialCruft.count).to eq(1)
    potential_cruft = IsThisUsed::PotentialCruft.first

    Fixtures::BaseCruft.new.hello
    expect(IsThisUsed::PotentialCruft.count).to eq(1)
    expect(potential_cruft.reload.invocations).to eq(0)

    Fixtures::ExampleCruft9.new('Zed').hello
    expect(IsThisUsed::PotentialCruft.count).to eq(1)
    expect(potential_cruft.reload.invocations).to eq(1)

    Fixtures::SpecificExampleCruft9.new('Matilda').hello
    expect(IsThisUsed::PotentialCruft.count).to eq(1)
    expect(potential_cruft.reload.invocations).to eq(1)

    Fixtures::EnthusiasticExampleCruft9.new('Clair').hello
    expect(IsThisUsed::PotentialCruft.count).to eq(1)
    expect(potential_cruft.reload.invocations).to eq(2)
  end

  it 'tracks private instance methods' do
    require 'dummy_app/models/fixtures/example_cruft10'

    expect(IsThisUsed::PotentialCruft.count).to eq(1)

    Fixtures::ExampleCruft10.new.do_something_privately

    expect(IsThisUsed::PotentialCruft.count).to eq(1)
    cruft = IsThisUsed::PotentialCruft.first
    expect(cruft.invocations).to eq(1)
  end

  it 'tracks protected instance methods' do
    require 'dummy_app/models/fixtures/example_cruft11'

    expect(IsThisUsed::PotentialCruft.count).to eq(1)

    Fixtures::ExampleCruft11.new.do_something_protected

    expect(IsThisUsed::PotentialCruft.count).to eq(1)
    cruft = IsThisUsed::PotentialCruft.first
    expect(cruft.invocations).to eq(1)
  end

  it 'tracks private class methods' do
    require 'dummy_app/models/fixtures/example_cruft12'

    expect(IsThisUsed::PotentialCruft.count).to eq(1)

    Fixtures::ExampleCruft12.do_the_sneaky_thing

    expect(IsThisUsed::PotentialCruft.count).to eq(1)
    cruft = IsThisUsed::PotentialCruft.first
    expect(cruft.invocations).to eq(1)
    expect(cruft.owner_name).to eq('Fixtures::ExampleCruft12')
    expect(cruft.method_name).to eq('be_sneaky')
  end
end