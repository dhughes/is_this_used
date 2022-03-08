# frozen_string_literal: true

# This migration must be kept in sync with
# `lib/generators/is_this_used/templates/create_potential_cruft_stacks.rb.erb`
# `lib/generators/is_this_used/templates/create_potential_crufts.rb.erb`
#
class SetUpTestTables < ::ActiveRecord::Migration::Current
  def up
    create_table :potential_crufts do |t|
      t.string :owner_name, null: false
      t.string :method_name, null: false
      t.string :method_type, null: false
      t.integer :invocations, null: false, default: 0
      t.datetime :deleted_at
      t.timestamps

      t.index :owner_name
      t.index :method_name
      t.index %i[owner_name method_name]
    end

    create_table :potential_cruft_stacks do |t|
      t.references :potential_cruft, null: false
      t.string :stack_hash, null: false, index: true
      t.json :stack, null: false
      t.integer :occurrences, null: false, index: true, default: 0
      t.timestamps
    end

    create_table :potential_cruft_arguments do |t|
      t.references :potential_cruft, null: false
      t.string :arguments_hash, null: false, index: true
      t.json :arguments, null: false
      t.integer :occurrences, null: false, index: true, default: 0
      t.timestamps
    end
  end

  def down
    # Not actually irreversible, but there is no need to maintain this method.
    raise ActiveRecord::IrreversibleMigration
  end
end
