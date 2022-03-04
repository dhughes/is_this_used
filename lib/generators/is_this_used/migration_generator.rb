# frozen_string_literal: true

require 'rails/generators'
require 'rails/generators/active_record'

module IsThisUsed
  class MigrationGenerator < Rails::Generators::Base
    include Rails::Generators::Migration

    source_root File.expand_path('templates', __dir__)

    def create_migration_file
      create_potential_crufts
      create_potential_cruft_stacks
      create_potential_cruft_arguments
    end

    def self.next_migration_number(dirname)
      ActiveRecord::Generators::Base.next_migration_number(dirname)
    end

    private

    def create_potential_crufts
      create_table('potential_crufts')
    end

    def create_potential_cruft_stacks
      create_table('potential_cruft_stacks')
    end

    def create_potential_cruft_arguments
      create_table('potential_cruft_arguments')
    end

    def create_table(table)
      migration_template(
        "create_#{table}.rb.erb",
        "db/migrate/create_#{table}.rb",
        { migration_version: migration_version }
      )
    end

    def migration_version
      format(
        '[%d.%d]',
        ActiveRecord::VERSION::MAJOR,
        ActiveRecord::VERSION::MINOR
      )
    end
  end
end
