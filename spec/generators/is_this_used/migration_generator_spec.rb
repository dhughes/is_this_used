# frozen_string_literal: true

require 'spec_helper'
require 'generator_spec/test_case'
require 'generators/is_this_used/migration_generator'

RSpec.describe IsThisUsed::MigrationGenerator, type: :generator do
  include GeneratorSpec::TestCase
  destination File.expand_path('tmp', __dir__)

  after { prepare_destination } # cleanup the tmp directory

  describe 'no options' do
    before do
      prepare_destination
      run_generator
    end

    it "generates a migration for creating the 'potential_crufts' table" do
      expected_parent_class = lambda do
        ar_class = 'ActiveRecord::Migration'
        ar_version = ActiveRecord::VERSION
        format('%s[%d.%d]', ar_class, ar_version::MAJOR, ar_version::MINOR)
      end.call

      expect(destination_root).to(
        have_structure do
          directory('db') do
            directory('migrate') do
              migration('create_potential_crufts') do
                contains(
                  'class CreatePotentialCrufts < ' + expected_parent_class
                )
                contains 'def change'
                contains 'create_table :potential_crufts'
              end
            end
          end
        end
      )
    end

    it "generates a migration for creating the 'potential_cruft_stacks' table" do
      expected_parent_class = lambda do
        ar_class = 'ActiveRecord::Migration'
        ar_version = ActiveRecord::VERSION
        format('%s[%d.%d]', ar_class, ar_version::MAJOR, ar_version::MINOR)
      end.call

      expect(destination_root).to(
        have_structure do
          directory('db') do
            directory('migrate') do
              migration('create_potential_cruft_stacks') do
                contains(
                  'class CreatePotentialCruftStacks < ' + expected_parent_class
                )
                contains 'def change'
                contains 'create_table :potential_cruft_stacks'
              end
            end
          end
        end
      )
    end
  end
end
