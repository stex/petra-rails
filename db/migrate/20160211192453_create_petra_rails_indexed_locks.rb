# frozen_string_literal: true

class CreatePetraRailsIndexedLocks < ActiveRecord::Migration
  def change
    create_table :petra_rails_indexed_locks do |t|
      t.string   :identifier, null: false
      t.timestamps null: false
    end

    add_index :petra_rails_indexed_locks, :identifier, unique: true
  end
end
